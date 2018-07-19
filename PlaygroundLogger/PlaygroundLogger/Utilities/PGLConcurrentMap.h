//===--- PGLConcurrentMap.h -----------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// PGLConcurrentMap provides an insertion-only map which allows for concurrent
// accesses with minimal overhead. Since this is extremely limited, the keys
// into this map are integers. (The values are arbitrary objects.)
//
//===----------------------------------------------------------------------===//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGLConcurrentMap : NSObject

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (BOOL)containsObjectForKey:(NSInteger)key;

- (nullable id)objectForKey:(NSInteger)key;

- (id)objectForKey:(NSInteger)key insertingObjectProvidedByBlockIfNotPresent:(id(^ NS_NOESCAPE)(void))objectProvider didInsert:(BOOL *)outDidInsert NS_REFINED_FOR_SWIFT;

- (id)objectForKey:(NSInteger)key insertingObjectIfNotPresent:(id)object didInsert:(BOOL *)outDidInsert NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
