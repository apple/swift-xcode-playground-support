//===--- LogPolicyTests.swift ---------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2018-2021 Apple Inc. and the Swift project authors
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

fileprivate class TestClass {
    let a: Int = 1
    init() {}
}

fileprivate class TestSubclass: TestClass {
    let b: Int = 2
    override init() { super.init() }
}

fileprivate class TestSubsubclass: TestSubclass {
    let c: Int = 3
    override init() { super.init() }
}

class LogPolicyTests: XCTestCase {
    func testMaximumDepthEnvironmentOverride() {
        setenv("LOGGER_DEPTH", "4", 0)
        let testPolicy = LogPolicy()
        
        XCTAssertEqual(testPolicy.maximumDepth, 4)
        unsetenv("LOGGER_DEPTH")
    }
    
    func testMaximumDepthLimitZero() throws {
        let testPolicy = LogPolicy(maximumDepth: 0)

        let logEntry = try LogEntry(describing: TestStruct(), name: "testStruct", policy: testPolicy)

        guard case let .structured(name, _, _, totalChildrenCount, children, disposition) = logEntry else {
            XCTFail("Expected a structured log entry for a struct")
            return
        }

        XCTAssertEqual(name, "testStruct")
        XCTAssertEqual(disposition, .struct)
        XCTAssertEqual(totalChildrenCount, 5)

        guard children.count == 1 else {
            XCTFail("Expected the struct to have exactly one child")
            return
        }

        guard case .gap = children[0] else {
            XCTFail("Expected the struct's only child to be a gap")
            return
        }
    }

    func testMaximumDepthLimitOne() throws {
        let testPolicy = LogPolicy(maximumDepth: 1)

        let logEntry = try LogEntry(describing: TestStruct(), name: "testStruct", policy: testPolicy)

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

    func testMaximumDepthLimitTwoWithSuperclasses() throws {
        let testPolicy = LogPolicy(maximumDepth: 2)

        check_TestClass: do {
            let logEntry = try LogEntry(describing: TestClass(), name: "testClass", policy: testPolicy)

            guard case let .structured(name, _, _, totalChildrenCount, children, disposition) = logEntry else {
                XCTFail("Expected a structured log entry for a class")
                return
            }

            XCTAssertEqual(name, "testClass")
            XCTAssertEqual(disposition, .class)
            XCTAssertEqual(totalChildrenCount, 1)

            guard children.count == 1 else {
                XCTFail("Expected TestClass to have exactly one child, but it had \(children.count)")
                break check_TestClass
            }

            check_child: do {
                guard case let .opaque(childName, childTypeName, _, _, childRepresentation) = children[0] else {
                    XCTFail("Expected an opaque log entry for the first child")
                    break check_TestClass
                }

                XCTAssertEqual(childName, "a")
                XCTAssertEqual(childTypeName, "Int")
                XCTAssertEqual(childRepresentation as? Int64, 1 as Int64)
            }
        }

        check_TestSubclass: do {
            let logEntry = try LogEntry(describing: TestSubclass(), name: "testSubclass", policy: testPolicy)

            guard case let .structured(name, _, _, totalChildrenCount, children, disposition) = logEntry else {
                XCTFail("Expected a structured log entry for a class")
                return
            }

            XCTAssertEqual(name, "testSubclass")
            XCTAssertEqual(disposition, .class)
            XCTAssertEqual(totalChildrenCount, 2)

            guard children.count == 2 else {
                XCTFail("Expected TestSubclass to have exactly two children, but it had \(children.count)")
                break check_TestSubclass
            }

            check_superclassChild: do {
                guard case let .structured(superclassName, _, _, superclassChildrenCount, superclassChildren, superclassDisposition) = children[0] else {
                    XCTFail("Expected a structured log entry for the first child (superclass)")
                    break check_TestSubclass
                }

                XCTAssertEqual(superclassName, "super")
                XCTAssertEqual(superclassChildrenCount, 1)
                XCTAssertEqual(superclassDisposition, .class)

                guard superclassChildren.count == 1 else {
                    XCTFail("Expected exactly one child of the superclass")
                    break check_superclassChild
                }

                guard case let .opaque(childName, childTypeName, _, _, childRepresentation) = superclassChildren[0] else {
                    XCTFail("Expected an opaque log entry for the first child")
                    break check_superclassChild
                }

                XCTAssertEqual(childName, "a")
                XCTAssertEqual(childTypeName, "Int")
                XCTAssertEqual(childRepresentation as? Int64, 1 as Int64)
            }

            check_child: do {
                guard case let .opaque(childName, childTypeName, _, _, childRepresentation) = children[1] else {
                    XCTFail("Expected an opaque log entry for the second child")
                    break check_TestSubclass
                }

                XCTAssertEqual(childName, "b")
                XCTAssertEqual(childTypeName, "Int")
                XCTAssertEqual(childRepresentation as? Int64, 2 as Int64)
            }
        }

        check_TestSubsubclass: do {
            let logEntry = try LogEntry(describing: TestSubsubclass(), name: "testSubsubclass", policy: testPolicy)

            guard case let .structured(name, _, _, totalChildrenCount, children, disposition) = logEntry else {
                XCTFail("Expected a structured log entry for a class")
                return
            }

            XCTAssertEqual(name, "testSubsubclass")
            XCTAssertEqual(disposition, .class)
            XCTAssertEqual(totalChildrenCount, 2)

            guard children.count == 2 else {
                XCTFail("Expected TestSubsubclass to have exactly two children, but it had \(children.count)")
                break check_TestSubsubclass
            }

            check_superclass: do {
                guard case let .structured(superclassName, _, _, superclassChildrenCount, superclassChildren, superclassDisposition) = children[0] else {
                    XCTFail("Expected a structured log entry for the first child (superclass)")
                    break check_superclass
                }

                XCTAssertEqual(superclassName, "super")
                XCTAssertEqual(superclassChildrenCount, 2)
                XCTAssertEqual(superclassDisposition, .class)

                guard superclassChildren.count == 2 else {
                    XCTFail("Expected exactly two children for the superclass")
                    break check_superclass
                }

                check_doubleSuperclass: do {
                    guard case let .structured(doubleSuperclassName, _, _, doubleSuperclassChildrenCount, doubleSuperclassChildren, doubleSuperclassDisposition) = superclassChildren[0] else {
                        XCTFail("Expected a structured log entry for the superclass's first child (double-superclass)")
                        break check_doubleSuperclass
                    }

                    XCTAssertEqual(doubleSuperclassName, "super")
                    XCTAssertEqual(doubleSuperclassChildrenCount, 1)
                    XCTAssertEqual(doubleSuperclassDisposition, .class)

                    guard doubleSuperclassChildren.count == 1 else {
                        XCTFail("Expected exactly one child for the double-superclass")
                        break check_doubleSuperclass
                    }

                    guard case .gap = doubleSuperclassChildren[0] else {
                        XCTFail("Expected the double-superclass's child to be a gap")
                        break check_doubleSuperclass
                    }
                }

                check_superclassChild: do {
                    guard case let .opaque(superclassChildName, superclassChildTypeName, _, _, superclassChildRepresentation) = superclassChildren[1] else {
                        XCTFail("Expected an opaque log entry for the superclass's second child")
                        break check_superclassChild
                    }

                    XCTAssertEqual(superclassChildName, "b")
                    XCTAssertEqual(superclassChildTypeName, "Int")
                    XCTAssertEqual(superclassChildRepresentation as? Int64, 2 as Int64)
                }
            }

            check_child: do {
                guard case let .opaque(childName, childTypeName, _, _, childRepresentation) = children[1] else {
                    XCTFail("Expected an opaque log entry for the second child")
                    break check_child
                }

                XCTAssertEqual(childName, "c")
                XCTAssertEqual(childTypeName, "Int")
                XCTAssertEqual(childRepresentation as? Int64, 3 as Int64)
            }
        }
    }

    func testContainerChildPolicyAll() throws {
        let testPolicy = LogPolicy(containerChildPolicy: .all)

        let array = Array(0...1000)
        let logEntry = try LogEntry(describing: array, name: "array", policy: testPolicy)

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

    func testContainerChildPolicyHead() throws {
        let testPolicy = LogPolicy(containerChildPolicy: .head(count: 10))

        let array = Array(0...1000)

        let logEntry = try LogEntry(describing: array, name: "array", policy: testPolicy)

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

    func testContainerChildPolicyHeadTail() throws {
        let testPolicy = LogPolicy(containerChildPolicy: .headTail(headCount: 10, tailCount: 5))

        let array = Array(0...1000)

        let logEntry = try LogEntry(describing: array, name: "array", policy: testPolicy)

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

    func testContainerChildPolicyNone() throws {
        let testPolicy = LogPolicy(containerChildPolicy: .none)

        let array = Array(0...1000)
        let logEntry = try LogEntry(describing: array, name: "array", policy: testPolicy)

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

    func testAggregateChildPolicyAll() throws {
        let testPolicy = LogPolicy(aggregateChildPolicy: .all)

        let logEntry = try LogEntry(describing: TestStruct(), name: "testStruct", policy: testPolicy)

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

    func testAggregateChildPolicyHead() throws {
        let testPolicy = LogPolicy(aggregateChildPolicy: .head(count: 2))

        let logEntry = try LogEntry(describing: TestStruct(), name: "testStruct", policy: testPolicy)

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

    func testAggregateChildPolicyHeadTail() throws {
        let testPolicy = LogPolicy(aggregateChildPolicy: .headTail(headCount: 2, tailCount: 1))

        let logEntry = try LogEntry(describing: TestStruct(), name: "testStruct", policy: testPolicy)

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

    func testAggregateChildPolicyNone() throws {
        let testPolicy = LogPolicy(aggregateChildPolicy: .none)

        let logEntry = try LogEntry(describing: TestStruct(), name: "testStruct", policy: testPolicy)

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
