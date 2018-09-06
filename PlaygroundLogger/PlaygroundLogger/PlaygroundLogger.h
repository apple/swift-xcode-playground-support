//===--- PlaygroundLogger.h -----------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2017-2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#import <Foundation/Foundation.h>

//! Project version number for PlaygroundLogger.
FOUNDATION_EXPORT double PlaygroundLoggerVersionNumber;

//! Project version string for PlaygroundLogger.
FOUNDATION_EXPORT const unsigned char PlaygroundLoggerVersionString[];

#import <PlaygroundLogger/PGLConcurrentMap.h>
#import <PlaygroundLogger/PGLThreadIsLogging.h>

#import <PlaygroundLogger/NSAttributedString+PGLKeyedArchivingUtilities.h>
#import <PlaygroundLogger/NSBezierPath+PGLKeyedArchivingUtilities.h>
#import <PlaygroundLogger/UIBezierPath+PGLKeyedArchivingUtilities.h>
