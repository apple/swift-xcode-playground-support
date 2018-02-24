//===--- LoggingError.swift -----------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/// A temporary function intended as a placeholder for real error handling, so that realistic error situations can be marked differently than a plain fatalError.
func loggingError(_ message: String? = nil) -> Never {
    if let message = message {
        fatalError("Error encountered while logging: \(message)")
    }
    else {
        fatalError("Error encountered while logging")
    }
}

