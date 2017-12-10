//===--- Unimplemented.swift ----------------------------------------------===//
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

@available(*, deprecated, message: "Unimplemented")
func unimplemented(_ message: String? = nil, _ function: String = #function, _ file: String = #file, _ line: Int = #line) -> Never {
    if let message = message {
        fatalError("\(file):\(line) - \(function) is unimplemented: \(message)")
    }
    else {
        fatalError("\(file):\(line) - \(function) is unimplemented")
    }
}
