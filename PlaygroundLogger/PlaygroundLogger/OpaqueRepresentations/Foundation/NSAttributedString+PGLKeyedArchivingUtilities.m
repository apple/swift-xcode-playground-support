//===--- NSAttributedString+PGLKeyedArchivingUtilities.m ------------------===//
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

#import <PlaygroundLogger/NSAttributedString+PGLKeyedArchivingUtilities.h>

@implementation NSAttributedString (PGLKeyedArchivingUtilities)

- (BOOL)pgl_encodeForLogEntryUsingEncoder:(NSCoder *)coder error:(NSError **)outError {
    @try {
        [coder encodeObject:self forKey:@"root"];
    }
    @catch (...) {
        if (outError) {
            *outError = [NSError errorWithDomain:@"PGLErrorDomain" code:-1 userInfo:@{
                NSLocalizedFailureReasonErrorKey: @"Encountered an exception when encoding an NSAttributedString",
            }];
        }
        return NO;
    }

    return YES;
}

@end
