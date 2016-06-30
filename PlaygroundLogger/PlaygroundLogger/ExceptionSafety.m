//
//  ExceptionSafety.m
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

#import "PlaygroundLogger.h"

@implementation SwiftExceptionSafety
+ (NSException *)doTry: (void(^)(void))block {
    @try {
        block();
    } @catch (NSException *err) {
        return err;
    }
        return nil;
}
- (id)init {
    return nil;
}
@end
