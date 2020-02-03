//===--- PGLNilObject.h ---------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// \c PGLNilObject is a test class which includes a \c -init method which is intentionally mis-annotated.
/// It returns \c nil instead of an instance of \c PGLNilObject to allow PlaygroundLogger's tests to exercise logging this sort of broken value.
///
/// See also: \c LogEntryTests.testNonOptionalNilObject()
@interface PGLNilObject : NSObject

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
