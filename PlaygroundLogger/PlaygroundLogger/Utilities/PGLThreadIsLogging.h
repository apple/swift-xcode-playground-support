//===--- PGLThreadIsLogging.h ---------------------------------------------===//
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

#import <sys/cdefs.h>
#import <stdbool.h>

__BEGIN_DECLS

/// A thread-local `bool` which indicates whether or not the current thread is
/// logging.
///
/// This is used by the functions in LoggerEntrypoints.swift and
/// LegacyEntrypoints.swift to prevent generating log packets while already
/// generating a log packet. It means the side-effects of logging are not
/// themselves logged.
extern __thread bool PGLThreadIsLogging;

/// A helper function to get the value of `PGLThreadIsLogging` safely from Swift.
static inline bool PGLGetThreadIsLogging(void) {
    return PGLThreadIsLogging;
}

/// A helper function to set the value of `PGLThreadIsLogging` safely from Swift.
static inline void PGLSetThreadIsLogging(bool threadIsLogging) {
    PGLThreadIsLogging = threadIsLogging;
}

__END_DECLS
