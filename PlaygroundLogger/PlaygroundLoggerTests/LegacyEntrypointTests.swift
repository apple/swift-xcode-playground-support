//===--- LegacyEntrypointTests.swift --------------------------------------===//
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

import XCTest
@testable import PlaygroundLogger

class LegacyEntrypointTests: XCTestCase {
    func testRecursiveLogging() {
        // Create a struct which, as a side effect of being logged, tries to log itself.
        // This is representative of a playground where `self` is logged in places like a CustomStringConvertible conformance.
        struct Struct: CustomStringConvertible {
            let x: Int
            let y: Int
            
            var description: String {
                // This direct call to the logger mirrors what would happen if this property were instrumented by the playground logger and there were a bare reference to `self`.
                let logData = legacyLog(instance: self, name: "self", id: 0, startLine: 1, endLine: 1, startColumn: 1, endColumn: 1)

                // Since `description` is only ever called by logging, we can assert that we have nil.
                // If we called `description` by other means we'd need to vary this assertion to match.
                XCTAssertNil(logData)

                return "(\(x), \(y))"
            }
        }

        let subject = Struct(x: 0, y: 0)

        // Log an instance of `Struct`. This should succeed (i.e. return data).
        let logData = legacyLog(instance: subject, name: "subject", id: 0, startLine: 1, endLine: 1, startColumn: 1, endColumn: 1)

        XCTAssertNotNil(logData)
    }
}
