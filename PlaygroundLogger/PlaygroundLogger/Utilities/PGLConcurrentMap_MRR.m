//===--- PGLConcurrentMap_MRR.m -------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014-2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// This file implements a concurrent insertion-only map which solely relies on
// atomics (instead of locks). It's inspired by the map used by the Swift
// runtime to metadata caches (swift/include/Runtime/Concurrent.h).
//
//===----------------------------------------------------------------------===//

#if __has_feature(objc_arc)
#error This source file expects to be compiled as MRR, not ARC
#endif

#import "PGLConcurrentMap.h"

#import <stdatomic.h>

// PGLConcurrentMapNode is effectively a reference counted struct.
// PGLConcurrentMap touches its instance variables directly to ensure appropriate atomicity.
__attribute__((visibility("hidden")))
@interface PGLConcurrentMapNode : NSObject {
@package
    _Atomic(PGLConcurrentMapNode *) left;
    _Atomic(PGLConcurrentMapNode *) right;
    NSInteger key;
    id <NSObject> value;
}

- (instancetype)initWithKey:(NSInteger)key value:(id)value;

@end

@implementation PGLConcurrentMapNode

- (instancetype)initWithKey:(NSInteger)key value:(id)value {
    if (self = [super init]) {
        self->left = ATOMIC_VAR_INIT(NULL);
        self->right = ATOMIC_VAR_INIT(NULL);
        self->key = key;
        self->value = [value retain];
    }
    return self;
}

- (void)dealloc {
    PGLConcurrentMapNode *left = atomic_load_explicit(&self->left, memory_order_relaxed);
    [left release];
    
    PGLConcurrentMapNode *right = atomic_load_explicit(&self->right, memory_order_relaxed);
    [right release];
    
    [self->value release];
    
    [super dealloc];
}

@end

@implementation PGLConcurrentMap {
    _Atomic(PGLConcurrentMapNode *) _root;
}

- (instancetype)init {
    if (self = [super init]) {
        _root = ATOMIC_VAR_INIT(nil);
    }
    return self;
}

- (BOOL)containsObjectForKey:(NSInteger)key {
    return NO;
}

- (id)objectForKey:(NSInteger)key {
    PGLConcurrentMapNode *node = atomic_load_explicit(&self->_root, memory_order_acquire);
    while (node) {
        NSInteger comparisonResult = (node->key - key);
        if (comparisonResult == 0) {
            return [[node->value retain] autorelease];
        }
        else if (comparisonResult < 0) {
            node = atomic_load_explicit(&node->left, memory_order_acquire);
        }
        else {
            node = atomic_load_explicit(&node->right, memory_order_acquire);
        }
    }
    return nil;
}

- (id)objectForKey:(NSInteger)key insertingObjectProvidedByBlockIfNotPresent:(id(^ NS_NOESCAPE)(void))objectProvider didInsert:(BOOL *)outDidInsert {
    // The node we created.
    PGLConcurrentMapNode *newNode = nil;
    
    // Start from the root.
    _Atomic(PGLConcurrentMapNode *) *edge = &self->_root;
    
    while (YES) {
        // Load the edge.
        PGLConcurrentMapNode *node = atomic_load_explicit(edge, memory_order_acquire);
        
        // If there's a node there, it's either a match or we're going to one of its children.
        if (node) {
        searchFromNode: {
            // Compare our key against the node's key.
            NSInteger comparisonResult = (node->key - key);
            
            // If it's equal, we can use this node.
            if (comparisonResult == 0) {
                // Destroy the node we allocated before if we're carrying one around.
                if (newNode) {
                    [newNode release];
                    newNode = nil;
                }
                
                // Report that we found an existing node.
                if (outDidInsert != NULL) {
                    *outDidInsert = NO;
                }
                
                return node->value;
            }
            
            // Otherwise, select the appropriate child edge and descend.
            edge = (comparisonResult < 0 ? &node->left : &node->right);
            continue;
        }
        }
        
        // Create a new node.
        if (!newNode) {
            newNode = [[PGLConcurrentMapNode alloc] initWithKey:key value:objectProvider()];
        }
        
        // Try to set the edge to the new node.
        if (atomic_compare_exchange_strong_explicit(edge, &node, newNode, memory_order_acq_rel, memory_order_acquire)) {
            // If that succeeded, report that we created a new node.
            if (outDidInsert != NULL) {
                *outDidInsert = YES;
            }
            return newNode->value;
        }
        
        assert(node && "spurious failure from compare_exchange_strong?");
        goto searchFromNode;
    }
}

- (id)objectForKey:(NSInteger)key insertingObjectIfNotPresent:(id)object didInsert:(BOOL *)outDidInsert {
    return [self objectForKey:key insertingObjectProvidedByBlockIfNotPresent:^{ return object; } didInsert:outDidInsert];
}

- (void)dealloc {
    PGLConcurrentMapNode *root = atomic_load_explicit(&self->_root, memory_order_relaxed);
    [root release];
    
    [super dealloc];
}

@end
