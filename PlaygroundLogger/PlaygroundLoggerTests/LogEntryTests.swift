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

#if os(macOS)
    import AppKit
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif

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

    func testEmptyView() throws {
        #if os(macOS)
            let emptyView = NSView()
        #elseif os(iOS) || os(tvOS)
            let emptyView = UIView()
        #endif

        let logEntry = try LogEntry(describing: emptyView, name: "emptyView", policy: .default)

        guard case let .opaque(name, _, _, _, representation) = logEntry else {
            XCTFail("Expected an opaque log entry")
            return
        }

        XCTAssertEqual(name, "emptyView")
        XCTAssert(representation is ImageOpaqueRepresentation)

        // Try to encode the log entry. This operation shouldn't throw; if it does, it will fail the test.
        let encoder = LogEncoder()
        try logEntry.encode(with: encoder, format: .current)
    }

    func testEmptyImage() throws {
        #if os(macOS)
            let emptyImage = NSImage()
        #elseif os(iOS) || os(tvOS)
            let emptyImage = UIImage()
        #endif

        let logEntry = try LogEntry(describing: emptyImage, name: "emptyImage", policy: .default)

        guard case let .opaque(name, _, _, _, representation) = logEntry else {
            XCTFail("Expected an opaque log entry")
            return
        }

        XCTAssertEqual(name, "emptyImage")
        XCTAssert(representation is ImageOpaqueRepresentation)

        // Try to encode the log entry. This operation shouldn't throw; if it does, it will fail the test.
        let encoder = LogEncoder()
        try logEntry.encode(with: encoder, format: .current)
    }
}
