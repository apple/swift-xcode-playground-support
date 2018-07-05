//===--- LogEntryTests.swift ----------------------------------------------===//
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

import Foundation

class LogEntryTests: XCTestCase {
    func testNilIUO() throws {
        let nilIUO: Int! = nil

        let logEntry = try LogEntry(describing: nilIUO as Any, name: "nilIUO", policy: .default)

        guard case let .structured(name, _, _, totalChildrenCount, children, _) = logEntry else {
            XCTFail("Expected a structured log entry")
            return
        }

        XCTAssertEqual(name, "nilIUO")
        XCTAssertEqual(totalChildrenCount, 0)
        XCTAssert(children.isEmpty)
    }
}
