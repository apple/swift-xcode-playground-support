//===--- CustomPlaygroundDisplayConvertibleTests.swift --------------------===//
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

import CoreGraphics

class CustomPlaygroundDisplayConvertibleTests: XCTestCase {
    func testBasicConformance() throws {
        struct MyPoint: CustomPlaygroundDisplayConvertible {
            let x: Int
            let y: Int

            var playgroundDescription: Any {
                return CGPoint(x: x, y: y)
            }
        }

        let point = MyPoint(x: 4, y: 3)

        let logEntry = try LogEntry(describing: point, name: "point", policy: .default)

        guard case let .opaque(name, typeName, _, _, representation) = logEntry else {
            XCTFail("Expected an instance of MyPoint to generate an opaque log entry")
            return
        }

        XCTAssertEqual(name, "point")
        XCTAssert(typeName.hasSuffix(".MyPoint"))

        guard let pointRepresentation = representation as? CGPoint else {
            XCTFail("Expected an instance of MyPoint to generate a CGPoint as its opaque representation")
            return
        }

        XCTAssertEqual(pointRepresentation, CGPoint(x: 4, y: 3))
    }
}
