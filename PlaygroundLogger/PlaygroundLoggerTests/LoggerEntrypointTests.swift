//===--- LoggerEntrypointTests.swift --------------------------------------===//
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

fileprivate var numberOfDataSent: Int = 0

fileprivate func countData(_: NSData) -> Void {
    numberOfDataSent += 1
}

class LoggerEntrypointTests: XCTestCase {
    override class func setUp() {
        super.setUp()

        // Tell PlaygroundLogger to use our function for counting data.
        PlaygroundLogger.sendData = countData
    }

    override class func tearDown() {
        super.tearDown()

        // Reset PlaygroundLogger.
        PlaygroundLogger.sendData = unsetSendData
    }

    override func setUp() {
        // Reset the data counter.
        numberOfDataSent = 0

        super.setUp()
    }

    func testRecursiveLogging() {
        // Create a struct which, as a side effect of being logged, tries to log itself.
        // This is representative of a playground where `self` is logged in places like a CustomStringConvertible conformance.
        struct Struct: CustomStringConvertible {
            let x: Int
            let y: Int

            var description: String {
                // Capture the previous number of data sent so we can check against it later.
                let previousNumberOfDataSent = numberOfDataSent

                // This direct call to the logger mirrors what would happen if this property were instrumented by the playground logger and there were a bare reference to `self`.
                PlaygroundLogger.logResult(self, named: "self", withIdentifier: 0, startLine: 1, endLine: 1, startColumn: 1, endColumn: 1)

                // Since `description` is only ever called by logging, we can assert that no additional data was sent.
                // If we called `description` by other means we'd need to vary this assertion to match.
                XCTAssertEqual(previousNumberOfDataSent, numberOfDataSent, "We don't expect any more data to be sent by that previous log line!")

                return "(\(x), \(y))"
            }
        }

        let subject = Struct(x: 0, y: 0)

        PlaygroundLogger.logResult(subject, named: "subject", withIdentifier: 0, startLine: 1, endLine: 1, startColumn: 1, endColumn: 1)

        XCTAssertEqual(numberOfDataSent, 1, "We expect only one data to be sent over the course of this test")
    }
}
