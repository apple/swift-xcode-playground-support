//
//  PlaygroundLogger.h
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

@import Foundation;
@import CoreGraphics;

@interface SwiftExceptionSafety : NSObject
- (id)init;
+ (NSException *)doTry:(void (^)(void))block;
@end
