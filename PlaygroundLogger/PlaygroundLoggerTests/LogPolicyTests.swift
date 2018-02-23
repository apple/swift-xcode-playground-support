//===--- LogPolicyTests.swift ---------------------------------------------===//
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

fileprivate struct TestStruct {
    let a: Int = 1
    let b: Int = 2
    let c: Int = 3
    let d: Int = 4
    let e: Int = 5

    init() {}
}

class LogPolicyTests: XCTestCase {
    func testContainerChildPolicyAll() {
        let testPolicy = LogPolicy(containerChildPolicy: .all)

        let array = Array(0...1000)
        let logEntry = LogEntry(describing: array, name: "array", policy: testPolicy)

        guard case let .structured(name, typeName, _, totalChildrenCount, children, disposition) = logEntry else {
            XCTFail("Expected a structured log entry for an array")
            return
        }

        XCTAssertEqual(name, "array")
        XCTAssertEqual(typeName, "Array<Int>")
        XCTAssertEqual(disposition, .indexContainer)
        XCTAssertEqual(totalChildrenCount, 1001)
        XCTAssertEqual(children.count, 1001)

        for (index, child) in children.enumerated() {
            guard case let .opaque(_, typeName, _, _, representation) = child else {
                XCTFail("Expected an opaque log entry for an item in the array")
                continue
            }

            XCTAssertEqual(typeName, "Int")

            guard let integer = representation as? Int64 else {
                XCTFail("Expected an Int64 as the representation for an Int")
                return
            }

            XCTAssertEqual(integer, Int64(index))
        }
    }

    func testContainerChildPolicyHead() {
        let testPolicy = LogPolicy(containerChildPolicy: .head(count: 10))

        let array = Array(0...1000)

        let logEntry = LogEntry(describing: array, name: "array", policy: testPolicy)

        guard case let .structured(name, typeName, _, totalChildrenCount, children, disposition) = logEntry else {
            XCTFail("Expected a structured log entry for an array")
            return
        }

        XCTAssertEqual(name, "array")
        XCTAssertEqual(typeName, "Array<Int>")
        XCTAssertEqual(disposition, .indexContainer)
        XCTAssertEqual(totalChildrenCount, 1001)

        guard children.count == 11 else {
            XCTFail("Expected exactly 11 children but have \(children.count)")
            return
        }

        for index in 0..<10 {
            let child = children[index]

            guard case let .opaque(_, typeName, _, _, representation) = child else {
                XCTFail("Expected an opaque log entry for an item in the array")
                continue
            }

            XCTAssertEqual(typeName, "Int")

            guard let integer = representation as? Int64 else {
                XCTFail("Expected an Int64 as the representation for an Int")
                return
            }

            XCTAssertEqual(integer, Int64(index))
        }

        let lastChild = children[10]
        guard case .gap = lastChild else {
            XCTFail("We expect the last child to be a gap entry indicating that items were omitted")
            return
        }
    }

    func testContainerChildPolicyHeadTail() {
        let testPolicy = LogPolicy(containerChildPolicy: .headTail(headCount: 10, tailCount: 5))

        let array = Array(0...1000)

        let logEntry = LogEntry(describing: array, name: "array", policy: testPolicy)

        guard case let .structured(name, typeName, _, totalChildrenCount, children, disposition) = logEntry else {
            XCTFail("Expected a structured log entry for an array")
            return
        }

        XCTAssertEqual(name, "array")
        XCTAssertEqual(typeName, "Array<Int>")
        XCTAssertEqual(disposition, .indexContainer)
        XCTAssertEqual(totalChildrenCount, 1001)

        guard children.count == 16 else {
            XCTFail("Expected exactly 16 children but have \(children.count)")
            return
        }

        for index in 0..<10 {
            let child = children[index]

            guard case let .opaque(_, typeName, _, _, representation) = child else {
                XCTFail("Expected an opaque log entry for an item in the array")
                continue
            }

            XCTAssertEqual(typeName, "Int")

            guard let integer = representation as? Int64 else {
                XCTFail("Expected an Int64 as the representation for an Int")
                return
            }

            XCTAssertEqual(integer, Int64(index))
        }

        let lastChild = children[10]
        guard case .gap = lastChild else {
            XCTFail("We expect the 11th child to be a gap entry indicating that items were omitted")
            return
        }

        for index in 11..<16 {
            let child = children[index]

            guard case let .opaque(_, typeName, _, _, representation) = child else {
                XCTFail("Expected an opaque log entry for an item in the array")
                continue
            }

            XCTAssertEqual(typeName, "Int")

            guard let integer = representation as? Int64 else {
                XCTFail("Expected an Int64 as the representation for an Int")
                return
            }

            XCTAssertEqual(integer, Int64(1000 - (15 - index)))
        }
    }

    func testContainerChildPolicyNone() {
        let testPolicy = LogPolicy(containerChildPolicy: .none)

        let array = Array(0...1000)
        let logEntry = LogEntry(describing: array, name: "array", policy: testPolicy)

        guard case let .structured(name, typeName, _, totalChildrenCount, children, disposition) = logEntry else {
            XCTFail("Expected a structured log entry for an array")
            return
        }

        XCTAssertEqual(name, "array")
        XCTAssertEqual(typeName, "Array<Int>")
        XCTAssertEqual(disposition, .indexContainer)
        XCTAssertEqual(totalChildrenCount, 1001)
        XCTAssertEqual(children.count, 0)
    }

    func testAggregateChildPolicyAll() {
        let testPolicy = LogPolicy(aggregateChildPolicy: .all)

        let logEntry = LogEntry(describing: TestStruct(), name: "testStruct", policy: testPolicy)

        guard case let .structured(name, _, _, totalChildrenCount, children, disposition) = logEntry else {
            XCTFail("Expected a structured log entry for a struct")
            return
        }

        XCTAssertEqual(name, "testStruct")
        XCTAssertEqual(disposition, .struct)
        XCTAssertEqual(totalChildrenCount, 5)
        XCTAssertEqual(children.count, 5)

        for (index, child) in children.enumerated() {
            guard case let .opaque(_, typeName, _, _, representation) = child else {
                XCTFail("Expected an opaque log entry for an item in the array")
                continue
            }

            XCTAssertEqual(typeName, "Int")

            guard let integer = representation as? Int64 else {
                XCTFail("Expected an Int64 as the representation for an Int")
                return
            }

            XCTAssertEqual(integer, Int64(index + 1))
        }
    }

    func testAggregateChildPolicyHead() {
        let testPolicy = LogPolicy(aggregateChildPolicy: .head(count: 2))

        let logEntry = LogEntry(describing: TestStruct(), name: "testStruct", policy: testPolicy)

        guard case let .structured(name, _, _, totalChildrenCount, children, disposition) = logEntry else {
            XCTFail("Expected a structured log entry for a struct")
            return
        }

        XCTAssertEqual(name, "testStruct")
        XCTAssertEqual(disposition, .struct)
        XCTAssertEqual(totalChildrenCount, 5)

        guard children.count == 3 else {
            XCTFail("Expected exactly 3 children but have \(children.count)")
            return
        }

        for index in 0..<2 {
            let child = children[index]

            guard case let .opaque(_, typeName, _, _, representation) = child else {
                XCTFail("Expected an opaque log entry for an item in the array")
                continue
            }

            XCTAssertEqual(typeName, "Int")

            guard let integer = representation as? Int64 else {
                XCTFail("Expected an Int64 as the representation for an Int")
                return
            }

            XCTAssertEqual(integer, Int64(index + 1))
        }

        guard case .gap = children[2] else {
            XCTFail("We expect the last child to be a gap entry indicating that items were omitted")
            return
        }
    }

    func testAggregateChildPolicyHeadTail() {
        let testPolicy = LogPolicy(aggregateChildPolicy: .headTail(headCount: 2, tailCount: 1))

        let logEntry = LogEntry(describing: TestStruct(), name: "testStruct", policy: testPolicy)

        guard case let .structured(name, _, _, totalChildrenCount, children, disposition) = logEntry else {
            XCTFail("Expected a structured log entry for a struct")
            return
        }

        XCTAssertEqual(name, "testStruct")
        XCTAssertEqual(disposition, .struct)
        XCTAssertEqual(totalChildrenCount, 5)

        guard children.count == 4 else {
            XCTFail("Expected exactly 4 children but have \(children.count)")
            return
        }

        for index in 0..<2 {
            let child = children[index]

            guard case let .opaque(_, typeName, _, _, representation) = child else {
                XCTFail("Expected an opaque log entry for an item in the array")
                continue
            }

            XCTAssertEqual(typeName, "Int")

            guard let integer = representation as? Int64 else {
                XCTFail("Expected an Int64 as the representation for an Int")
                return
            }

            XCTAssertEqual(integer, Int64(index + 1))
        }

        guard case .gap = children[2] else {
            XCTFail("We expect the child at index 2 to be a gap entry indicating that items were omitted")
            return
        }

        guard case let .opaque(_, typeName, _, _, representation) = children[3] else {
            XCTFail("Expected an opaque log entry for the last child")
            return
        }

        XCTAssertEqual(typeName, "Int")

        guard let integer = representation as? Int64 else {
            XCTFail("Expected an Int64 as the representation for an Int")
            return
        }

        XCTAssertEqual(integer, 5)
    }

    func testAggregateChildPolicyNone() {
        let testPolicy = LogPolicy(aggregateChildPolicy: .none)

        let logEntry = LogEntry(describing: TestStruct(), name: "testStruct", policy: testPolicy)

        guard case let .structured(name, _, _, totalChildrenCount, children, disposition) = logEntry else {
            XCTFail("Expected a structured log entry for a struct")
            return
        }

        XCTAssertEqual(name, "testStruct")
        XCTAssertEqual(disposition, .struct)
        XCTAssertEqual(totalChildrenCount, 5)
        XCTAssertEqual(children.count, 0)
    }
}
