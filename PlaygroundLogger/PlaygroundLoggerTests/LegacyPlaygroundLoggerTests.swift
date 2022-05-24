//===--- LegacyPlaygroundLoggerTests.swift --------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014-2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// This file contains code ported from the legacy/original implementation of
// PlaygroundLogger. This is to support porting the tests from the legacy
// PlaygroundLogger as-is (i.e. using the original test decoder) in order to
// validate the new implementation.
//
//===----------------------------------------------------------------------===//

import Foundation

#if os(macOS)
    import AppKit

    typealias ImageType = NSImage
#elseif os(iOS) || os(tvOS)
    import UIKit

    typealias ImageType = UIImage
#endif

import SpriteKit

import XCTest

@testable import PlaygroundLogger

// MARK: - TestCases.swift (adapted to XCTest)

class LegacyPlaygroundLoggerTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        legacyInitializePlaygroundLogger()
    }
    
    func testVersionDecoding() {
        let logdata = legacyLog(instance: 1, name: "", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        XCTAssertEqual(10, decoded.version)
    }
    
    func testSourceRanges() {
        let myrange = SourceRange(begin: (line: 12, col: 3), end: (line: 13, col: 2))
        let logdata = legacyLog(instance: 1,
                                name: "",
                                id: 0,
                                startLine: Int(myrange.begin.line),
                                endLine: Int(myrange.end.line),
                                startColumn: Int(myrange.begin.col),
                                endColumn: Int(myrange.end.col)) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        XCTAssertEqual(myrange.begin.line, decoded.range.begin.line)
        XCTAssertEqual(myrange.begin.col, decoded.range.begin.col)
        XCTAssertEqual(myrange.end.line, decoded.range.end.line)
        XCTAssertEqual(myrange.end.col, decoded.range.end.col)
    }
    
    func testTIDSent() {
        let logdata = legacyLog(instance: 1, name: "", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        var found = false
        for (key,value) in decoded.header {
            if key == "tid" {
                if Int(value) != nil {
                    found = true
                }
            }
        }
        XCTAssertTrue(found)
    }
    
    func testNameDecoding() {
        struct S { var a = 1; var b = 2; }
        let logdata = legacyLog(instance: S(), name: "s", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        let s = decoded.object
        XCTAssertEqual("s", s.name)
        guard let structured = s as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }
        XCTAssertEqual(2, structured.count)
        let child0 = structured[0]
        let child1 = structured[1]
        XCTAssertEqual(child0.name,"a")
        XCTAssertEqual(child1.name,"b")
    }
    
    func testBaseTypesDecoding() {
        struct S { var a = 1; var b = "hello world"; var c: Double = 12.15; var d: Float = 12.15 }
        let logdata = legacyLog(instance: S(), name: "s", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let structured = decoded.object as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }
        XCTAssertEqual(4, structured.count)
        let child0 = structured[0]
        let child1 = structured[1]
        let child2 = structured[2]
        let child3 = structured[3]
        guard let child0_iderepr = child0 as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("child0 is not IDERepr")
            return
        }
        guard let child1_iderepr = child1 as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("child1 is not IDERepr")
            return
        }
        guard let child2_iderepr = child2 as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("child2 is not IDERepr")
            return
        }
        guard let child3_iderepr = child3 as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("child3 is not IDERepr")
            return
        }
        guard let child0Payload = child0_iderepr.payload, let aInt64 = child0Payload as? Int64 else {
            XCTFail("child0 does not contain expected payload type")
            return
        }
        let a = Int(aInt64)
        guard let child1Payload = child1_iderepr.payload, let b = child1Payload as? String else {
            XCTFail("child1 does not contain expected payload type")
            return
        }
        guard let child2Payload = child2_iderepr.payload, let c = child2Payload as? Double else {
            XCTFail("child2 does not contain expected payload type")
            return
        }
        guard let child3Payload = child3_iderepr.payload, let d = child3Payload as? Float else {
            XCTFail("child3 does not contain expected payload type")
            return
        }
        let realS = S()
        XCTAssertEqual(a, realS.a)
        XCTAssertEqual(b, realS.b)
        XCTAssertEqual(c, realS.c)
        XCTAssertEqual(d, realS.d)
    }
    
    func testStructuredTypesDecoding() {
        struct S {}
        class C {}
        
        let s_logdata = legacyLog(instance: S(), name: "s", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        let c_logdata = legacyLog(instance: C(), name: "c", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        let t_logdata = legacyLog(instance: (1, 1), name: "t", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        
        guard let s_decoded = legacyLogDecode(s_logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let c_decoded = legacyLogDecode(c_logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let t_decoded = legacyLogDecode(t_logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        
        guard let s = s_decoded.object as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }
        guard let c = c_decoded.object as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }
        guard let t = t_decoded.object as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }

        
        XCTAssertEqual(s.type, PlaygroundRepresentation.Struct.description)
        XCTAssertEqual(c.type, PlaygroundRepresentation.Class.description)
        XCTAssertEqual(t.type, PlaygroundRepresentation.Tuple.description)
    }
    
    func testNSNumberDecoding() {
        let num: NSNumber = NSNumber(value: 12345)
        let logdata = legacyLog(instance: num, name: "num", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let iderepr = decoded.object as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("Decoded object is not IDERepr")
            return
        }
        guard let data = iderepr.payload else {
            XCTFail("IDERepr is missing payload")
            return
        }
        XCTAssertEqual("\(data)", "12345")
    }
    
    func testOnePlusOneDecoding() {
        let logdata = legacyLog(instance: 1+1, name: "num", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let iderepr = decoded.object as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("Decoded object is not IDERepr")
            return
        }
        let summary = iderepr.summary
        XCTAssertEqual(summary, "2")
    }
    
    func testMetatypeLogging() {
        struct S {}
        let logdata = legacyLog(instance: S.self, name: "S", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        XCTAssert(decoded.object is PlaygroundDecodedObject_Structured)
    }
    
    // testExceptionSafety() is excluded, as it tests functionality handled differently in the new implementation.
    
    #if os(macOS)
    func testNSViewLogging() {
        let button = NSButton(frame: NSRect(x: 0,y: 0,width: 100,height: 100))
        let logdata  = legacyLog(instance: button, name: "button", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let iderepr = decoded.object as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("Decoded object is not IDERepr")
            return
        }
        XCTAssertEqual(iderepr.tag, "VIEW")

        guard let payloadImage = iderepr.payload as? NSImage else {
            XCTFail("Decoded payload is not an image")
            return
        }
        XCTAssertEqual(payloadImage.size, NSSize(width: 100, height: 100))

    }
    #endif

    #if os(iOS) || os(tvOS)
    func testUIViewLogging() {
        let button = UIButton(type: .system)
        button.setTitle("Button", for: .normal)
        button.sizeToFit()

        let logdata = legacyLog(instance: button, name: "button", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let iderepr = decoded.object as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("Decoded object is not IDERepr")
            return
        }
        XCTAssertEqual(iderepr.tag, "VIEW")

        guard let payloadImage = iderepr.payload as? UIImage else {
            XCTFail("Decoded payload is not an image")
            return
        }
        XCTAssertEqual(payloadImage.size, CGSize(width: button.bounds.size.width * UIScreen.main.scale, height: button.bounds.size.height * UIScreen.main.scale))
    }
    #endif
    
    func testImageLogging() {
        let size = CGSize(width: 30, height: 30)

        #if os(macOS)
            let image = NSImage(size: size, flipped: false) { rect -> Bool in
                NSColor.white.setFill()
                NSBezierPath(rect: rect).fill()
                NSColor.orange.setFill()
                NSBezierPath(roundedRect: rect.insetBy(dx: 5, dy: 5), xRadius: 3, yRadius: 3).fill()
                return true
            }
        #elseif os(iOS) || os(tvOS)
            let rendererFormat: UIGraphicsImageRendererFormat
            if #available(iOS 11.0, tvOS 11.0, *) {
                rendererFormat = .preferred()
            }
            else {
                rendererFormat = .default()
            }
            rendererFormat.scale = 1
            rendererFormat.opaque = true

            let image = UIGraphicsImageRenderer(size: size, format: rendererFormat).image { context in
                UIColor.white.setFill()
                UIBezierPath(rect: context.format.bounds).fill()
                UIColor.orange.setFill()
                UIBezierPath(roundedRect: context.format.bounds.insetBy(dx: 5, dy: 5), cornerRadius: 3).fill()
            }
        #endif

        let logdata  = legacyLog(instance: image, name: "image", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let iderepr = decoded.object as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("Decoded object is not IDERepr")
            return
        }
        XCTAssertEqual(iderepr.tag, "IMAG")

        guard let payloadImage = iderepr.payload as? ImageType else {
            XCTFail("Decoded payload is not an image")
            return
        }

        let expectedSize: CGSize
        #if os(macOS)
            // On macOS, the image we create above is rendered at a scale factor. We get the best-available scale factor from all screens and use that when creating our expectation.
            let scaleFactor = NSScreen.screens.reduce(1.0) { previousBestScaleFactor, screen in
                return max(previousBestScaleFactor, screen.backingScaleFactor)
            }

            expectedSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        #elseif os(iOS) || os(tvOS)
            // On iOS and tvOS, we expect the output image to be the same size as the input image.
            expectedSize = size
        #endif

        XCTAssertEqual(payloadImage.size, expectedSize)
    }
    
    // testSpriteKitLogging() is excluded, as it cannot be trivially ported.
    
    func testOptionalGetsStripped() {
        let some: String?? = "hello"
        let none: String?? = nil
        
        let some_logged = legacyLog(instance: some, name: "some", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        let none_logged = legacyLog(instance: none, name: "none", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        
        guard let some_decoded = legacyLogDecode(some_logged) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let none_decoded = legacyLogDecode(none_logged) else {
            XCTFail("Failed to decode log data")
            return
        }

        guard let some_iderepr = some_decoded.object as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("Decoded object is not IDERepr")
            return
        }
        guard let none_structured = none_decoded.object as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }

        XCTAssertEqual(none_structured.summary, "nil")
        XCTAssertEqual(some_iderepr.tag, "STRN")
        XCTAssertEqual(some_iderepr.summary, "hello")
    }
    
    // testStackWorks(), testNeverLoggingPolicy(), and testAdaptiveLoggingPolicy() are excluded, as they test functionality omitted from the new implementation.
    
    func testSetIsMembershipContainer() {
        let object = Set([1,2,3])
        let logdata = legacyLog(instance: object, name: "object", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let set_structured = decoded.object as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }
        XCTAssertEqual("MembershipContainer", set_structured.type)
    }
    
    func testTypenameManagement() {
        struct SomeStruct {
            var a = 12
            var b = 24
        }
        var object: Any = SomeStruct()
        var logdata = legacyLog(instance: object, name: "object", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        var decoded: PlaygroundDecodedLogEntry!
        var structured: PlaygroundDecodedObject_Structured!
        func decodeLogdata() {
            guard let decodedTemp = legacyLogDecode(logdata) else {
                XCTFail("Failed to decode log data")
                return
            }
            decoded = decodedTemp
            
            guard let structuredTemp = decoded.object as? PlaygroundDecodedObject_Structured else {
                XCTFail("Decoded object is not structured")
                return
            }
            structured = structuredTemp
        }
        decodeLogdata()
            
        XCTAssert(structured.typeName.hasSuffix(".SomeStruct"))
        object = (1,2,2,4)
        logdata = legacyLog(instance: object, name: "object", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        decodeLogdata()
        XCTAssertEqual("(Int, Int, Int, Int)", structured.typeName)
        object = [1: "1", 2: "2"]
        logdata = legacyLog(instance: object, name: "object", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        decodeLogdata()
        XCTAssertEqual("Dictionary<Int, String>", structured.typeName)
        class Foo { class Swift { class Bar { class Baz { } } } }
        object = Foo.Swift.Bar.Baz()
        logdata = legacyLog(instance: object, name: "object", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        decodeLogdata()
        XCTAssert(structured.typeName.hasSuffix(".Foo.Swift.Bar.Baz"))
    }
    
    func testFloatDoubleDecoding() {
        let f: Float = 1.25
        let d: Double = 1.25
        let f_ld = legacyLog(instance: f, name: "f", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        let d_ld = legacyLog(instance: d, name: "d", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let f_dc = legacyLogDecode(f_ld) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let d_dc = legacyLogDecode(d_ld) else {
            XCTFail("Failed to decode log data")
            return
        }
        
        guard let f_repr = f_dc.object as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("Decoded object is not IDERepr")
            return
        }
        guard let d_repr = d_dc.object as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("Decoded object is not IDERepr")
            return
        }
        
        XCTAssertEqual(f_repr.tag, "FLOT")
        XCTAssertEqual(d_repr.tag, "DOBL")
        
        guard let f2 = f_repr.payload as? Float else {
            XCTFail("Payload is not expected type")
            return
        }
        guard let d2 = d_repr.payload as? Double else {
            XCTFail("Payload is not expected type")
            return
        }
        
        XCTAssertEqual(f, f2)
        XCTAssertEqual(d, d2)
    }

    func testSKShapeNode() {
        let blahNode = SKShapeNode(circleOfRadius: 30.0)
        let logdata = legacyLog(instance: blahNode, name: "blahNode", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let bn_repr = decoded.object as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("Decoded object is not IDERepr")
            return
        }
        XCTAssertEqual(bn_repr.tag, "SKIT")
        XCTAssertEqual(bn_repr.typeName, "SKShapeNode")

        XCTAssert(bn_repr.payload is ImageType, "We expect the payload to be an image")
    }
    
    func testBaseClassLogging() {
        class Parent { var a = 1; var b = 2 }
        class Child : Parent { var c = 3 }
        let object = Child()
        let logdata = legacyLog(instance: object, name: "object", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let structured = decoded.object as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }
        var seen_parent = false
        var seen_a = false
        var seen_b = false
        var seen_c = false
        for child in structured.children {
            if let structured_child = child as? PlaygroundDecodedObject_Structured {
                if structured_child.name == "super" {
                    seen_parent = true
                    for parent_child in structured_child.children {
                        if parent_child.name == "a" { seen_a = true }
                        if parent_child.name == "b" { seen_b = true }
                    }
                }
            }
            if child.name == "c" {
                seen_c = true
            }
        }
        XCTAssert(seen_parent && seen_a && seen_b && seen_c)
    }
    
    func testEnumSummary_Generic() {
        typealias GEither = EnumSummaryTestCase_GEither<Int,String>
        let t1 = GEither.First(1)
        let t2 = GEither.Second("A")
        let t3 = GEither.Neither
        
        let logdata_t1 = legacyLog(instance: t1, name: "t1", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        let logdata_t2 = legacyLog(instance: t2, name: "t2", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        let logdata_t3 = legacyLog(instance: t3, name: "t3", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        
        guard let decoded_t1 = legacyLogDecode(logdata_t1) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let decoded_t2 = legacyLogDecode(logdata_t2) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let decoded_t3 = legacyLogDecode(logdata_t3) else {
            XCTFail("Failed to decode log data")
            return
        }

        guard let structured_t1 = decoded_t1.object as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }
        guard let structured_t2 = decoded_t2.object as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }
        guard let structured_t3 = decoded_t3.object as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }
        
        XCTAssertEqual(structured_t1.summary, "First(1)")
        XCTAssertEqual(structured_t2.summary, "Second(\"A\")")
        XCTAssertEqual(structured_t3.summary, "Neither")
    }
    
    func testEnumSummary_NotGeneric() {
        typealias Either = EnumSummaryTestCase_Either
        let t1 = Either.First(1)
        let t2 = Either.Second("A")
        let t3 = Either.Neither
        
        let logdata_t1 = legacyLog(instance: t1, name: "t1", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        let logdata_t2 = legacyLog(instance: t2, name: "t2", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        let logdata_t3 = legacyLog(instance: t3, name: "t3", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        
        guard let decoded_t1 = legacyLogDecode(logdata_t1) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let decoded_t2 = legacyLogDecode(logdata_t2) else {
            XCTFail("Failed to decode log data")
            return
        }
        guard let decoded_t3 = legacyLogDecode(logdata_t3) else {
            XCTFail("Failed to decode log data")
            return
        }
        
        guard let structured_t1 = decoded_t1.object as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }
        guard let structured_t2 = decoded_t2.object as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }
        guard let structured_t3 = decoded_t3.object as? PlaygroundDecodedObject_Structured else {
            XCTFail("Decoded object is not structured")
            return
        }
        
        XCTAssertEqual(structured_t1.summary, "First(1)")
        XCTAssertEqual(structured_t2.summary, "Second(\"A\")")
        XCTAssertEqual(structured_t3.summary, "Neither")
    }
    
    func testPrintHook() {
        printHook(string: "hello world")
        
        let logdata_1 = legacyLogPostPrint(startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded_1 = legacyLogDecode(logdata_1), let iderepr_1 = decoded_1.object as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("Decoded object is not IDERepr")
            return
        }
        XCTAssertEqual(iderepr_1.summary, "hello world")
        
        printHook(string: "not this one")
        printHook(string: "but this one")
        
        let logdata_2 = legacyLogPostPrint(startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded_2 = legacyLogDecode(logdata_2), let iderepr_2 = decoded_2.object as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("Decoded object is not IDERepr")
            return
        }
        XCTAssertEqual(iderepr_2.summary, "but this one")
    }
    
    func testPlaygroundQuickLookCalledOnce() {
        class MyObject : _CustomPlaygroundQuickLookable {
            var numCalls = 0
            var customPlaygroundQuickLook: _PlaygroundQuickLook {
                get {
                    numCalls = numCalls + 1
                    return .text("Hello world")
                }
            }
        }
        
        let object = MyObject()
        _ = legacyLog(instance: object, name: "object", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0)
        
        XCTAssertEqual(object.numCalls, 1)
    }
    
    // testUInt64EightBytesEncoding(), testNSColorLogging(), and testStructLogging() are excluded, as in their current form they test implementation details of the legacy logger.

    // MARK: - New Tests Using Legacy Infrastructure

    // These are tests which did not exist in the previous test suite, but which use the legacy infrastructure to run.
    // They should be migrated to new test infrastructure once such a thing exists.

    func testCGFloatLogging() {
        let cgFloat: CGFloat = 2.0
        let logdata = legacyLog(instance: cgFloat, name: "cgFloat", id: 0, startLine: 0, endLine: 0, startColumn: 0, endColumn: 0) as! NSData
        guard let decoded = legacyLogDecode(logdata), let iderepr = decoded.object as? PlaygroundDecodedObject_IDERepr else {
            XCTFail("Decoded object is not IDERepr")
            return
        }

        XCTAssertEqual(iderepr.name, "cgFloat")
        XCTAssertEqual(iderepr.typeName, "CoreGraphics.CGFloat")
        XCTAssertEqual(iderepr.summary, "2.0")

        if CGFloat.NativeType.self == Double.self {
            XCTAssertEqual(iderepr.tag, "DOBL")
            guard iderepr.payload is Double else {
                XCTFail("Expected a Double as payload but did not have one")
                return
            }
            XCTAssertEqual(iderepr.payload as! Double, 2.0 as Double)
        }
        else if CGFloat.NativeType.self == Float.self {
            XCTAssertEqual(iderepr.tag, "FLOT")
            guard iderepr.payload is Float else {
                XCTFail("Expected a Float as payload but did not have one")
                return
            }
            XCTAssertEqual(iderepr.payload as! Float, 2.0 as Float)
        }
        else {
            XCTFail("Unknown CGFloat.NativeType: \(CGFloat.NativeType.self)")
        }
    }
}

// generic so can't be nested in the test case itself
fileprivate enum EnumSummaryTestCase_GEither<T1,T2> { case First(T1), Second(T2), Neither }
fileprivate enum EnumSummaryTestCase_Either { case First(Int), Second(String), Neither }

// MARK: - Common.swift

typealias SourceLocation = (line: UInt64, col: UInt64)
typealias SourceRange = (begin: SourceLocation, end: SourceLocation)

// MARK: - BytesStorage.swift

final class BytesStorage {
	let data: NSData // hold on to the NSData so it doesn't go away from under us
	let bytes: UnsafeMutablePointer<UInt8> // but a pointer is good enough to actually index bytes by
	var index: Int
	
	init(_ _bytes: NSData) {
		data = _bytes
		bytes = UnsafeMutablePointer(mutating: data.bytes.bindMemory(to: UInt8.self, capacity: data.length))
		index = 0
	}
		
	func get() -> UInt8 {
        let i = index
        index += 1
		return bytes[i]
	}
	
	func peek() -> UInt8 {
		return bytes[index]
	}
	
	func eof() -> Bool {
		return index >= count
	}
	
    var count: Int {
        get { return data.length }
	}
	
	subscript (i: UInt64) -> UInt8 {
		get {
	    	return bytes[index+Int(i)]
		}
	}
	
	func has(_ nBytes: UInt64) -> Bool {
		return (index+Int(nBytes) <= count)
	}
    
    func dumpBytes() {
        for idx in 0..<count {
            let byte : UInt8 = self.bytes[idx]
            print("\(byte) ", terminator: "")
        }
        print("")
    }
    
    func subset(len: UInt64, consume: Bool) -> BytesStorage {
        let copydata = NSData(bytesNoCopy:bytes+index, length: Int(len), freeWhenDone: false)
        if consume {
            index = index + Int(len)
        }
        return BytesStorage(copydata)
    }
}

// MARK: - PlaygroundRepresentation.swift

enum PlaygroundRepresentation : UInt8, Hashable, CustomStringConvertible, Equatable {
    case Class = 1
    case Struct = 2
    case Tuple = 3
    case Enum = 4
    case Aggregate = 5
    case Container = 6
    case IDERepr = 7
    case Gap = 8
    case ScopeEntry = 9
    case ScopeExit = 10
    case Error = 11
    case IndexContainer = 12
    case KeyContainer = 13
    case MembershipContainer = 14
    case Unknown = 0xFF
	
	init (byte: UInt8) {
        if let repr = PlaygroundRepresentation(rawValue: byte) {
            self = repr
        } else {
            self = .Unknown
        }
	}
    
    init? (storage : BytesStorage) {
        self = PlaygroundRepresentation(byte: storage.get())
    }
    
	var hashValue : Int {
        return Int(self.rawValue)
	}
    
    var description: String {
        switch self {
        case .Class: return "Class"
        case .Struct: return "Struct"
        case .Tuple: return "Tuple"
        case .Enum: return "Enum"
        case .Aggregate: return "Aggregate"
        case .Container: return "Container"
        case .IDERepr: return "IDERepr"
        case .Gap: return "Gap"
        case .ScopeEntry: return "ScopeEntry"
        case .ScopeExit: return "ScopeExit"
        case .Error: return "Error"
        case .IndexContainer: return "IndexContainer"
        case .KeyContainer: return "KeyContainer"
        case .MembershipContainer: return "MembershipContainer"
        default: return "Unknown"
        }
    }
    
    init(_ x: Mirror.DisplayStyle)
    {
        switch (x) {
        case .`class`: self = .Class
        case .`struct`: self = .Struct
        case .tuple: self = .Tuple
        case .`enum`: self = .Enum
        case .optional: self = .Aggregate
        case .collection: self = .IndexContainer
        case .dictionary: self = .KeyContainer
        case .set: self = .MembershipContainer
        @unknown default: self = .Container
        }
    }
}

// MARK: - KeyedUnarchiver.swift

final class LoggerUnarchiver {
   var unarchiver : NSKeyedUnarchiver
   let storage : BytesStorage
   
   init(_ stg : BytesStorage) {
      storage = stg
      unarchiver = NSKeyedUnarchiver(forReadingWith: NSData(bytes: storage.bytes + storage.index, length: storage.count - storage.index) as Data)
   }
   
   func get(double: String) -> Double {
    return unarchiver.decodeDouble(forKey: double)
   }
   
   func get(bool : String) -> Bool {
    return unarchiver.decodeBool(forKey: bool)
   }
   
   func get(int64 : String) -> Int64 {
    return unarchiver.decodeInt64(forKey: int64)
   }
   
   func get(uint64 : String) -> UInt64 {
    return UInt64(unarchiver.decodeInt64(forKey: uint64))
   }
   
   func get(object : String) -> Any! {
    return unarchiver.decodeObject(forKey: object)
   }
   
   func has(_ key : String) -> Bool {
    switch unarchiver.decodeObject(forKey: key) {
        case nil: return false
        default: return true
    }
   }
}

// MARK: - ExtensionUInt64.swift

extension UInt64 {
	static let largeNumMarker : UInt8 = 0xFF
	
	init? (storage : BytesStorage) {
		let byte0 = storage.get()
		if (byte0 == UInt64.largeNumMarker) {
            if let x = UInt64(eightBytesStorage: storage) {
                self = x
            } else {
                return nil
            }
		} else {
			self = UInt64(byte0)
		}
	}

    init? (eightBytesStorage: BytesStorage) {
        if !eightBytesStorage.has(8) { return nil }
		let up_byte = UnsafeMutablePointer<UInt8>.allocate(capacity: 8)
        defer { up_byte.deallocate() }
        for idx in 0..<8 {
            up_byte[idx] = eightBytesStorage.get()
        }
        let up_int: UnsafePointer<UInt64> = UnsafeRawPointer(up_byte).bindMemory(
            to: UInt64.self, capacity: 1)
		self = up_int.pointee
    }
}

// MARK: - ExtensionString.swift

extension String {
	init (rawBytes: [UInt8]) {
        self = String(decoding: rawBytes, as: UTF8.self)
    }
    
    init? (storage: BytesStorage) {
		var str_bytes = Array<UInt8>()
        guard let count = UInt64(storage: storage) else { return nil }
        if count == 0 {
            self = ""
        } else {
            if !storage.has(count) { return nil }
            for _ in 0..<count {
                let byte = storage.get()
                str_bytes.append(byte)
            }
            self = String(rawBytes: str_bytes)
        }
	}
    
    init? (fullBytesStorage: BytesStorage) {
        var str_bytes = Array<UInt8>()
        while fullBytesStorage.has(1) {
            let byte = fullBytesStorage.get()
            str_bytes.append(byte)
        }
        self = String(rawBytes: str_bytes)
    }
}

extension String {
    var byteLength: Int {
        return self.utf8.count
    }
}

// MARK: - ExtensionBool.swift

extension Bool {
    init? (storage: BytesStorage) {
        let b = storage.get()
        if b == 1 { self = true }
        else if b == 0 { self = false }
        else { return nil }
    }
}

// MARK: - ExtensionFloat.swift

extension Float {
    init? (storage: BytesStorage) {
        let ubPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
        defer { ubPtr.deallocate() }
        for idx in 0..<4 {
            ubPtr[idx] = storage.get()
        }
        let udPtr = UnsafeMutableRawPointer(ubPtr).bindMemory(
            to: Float.self, capacity: 1)
        self = udPtr.pointee
    }
}

// MARK: - ExtensionDouble.swift

extension Double {
    init? (storage: BytesStorage) {
        let ubPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: 8)
        defer { ubPtr.deallocate() }
        for idx in 0..<8 {
            ubPtr[idx] = storage.get()
        }
        let udPtr = UnsafeMutableRawPointer(ubPtr).bindMemory(
            to: Double.self, capacity: 1)
        self = udPtr.pointee
    }
}

// MARK: - LoggerDecoderAPI.swift

// LoggerDecoder is not meant for public consumption, is not complete
// and is distinct from the decoder logic used by Xcode - the purpose
// of this decoding API is to enable testing of PlaygroundLogger

public class PlaygroundDecodedLogEntry {
    let version: UInt64
    let range: SourceRange
    let header: [String: String]
    let object: PlaygroundDecodedObject
    
    init (version: UInt64,
          startLine: UInt64,
          startColumn: UInt64,
          endLine: UInt64,
          endColumn: UInt64,
          header: [String: String],
          object: PlaygroundDecodedObject) {
        self.version = version
        self.range = SourceRange(begin: (line: startLine, col: startColumn), end: (line: endLine, col: endColumn))
        self.header = header
        self.object = object
    }
    
    func print<T: TextOutputStream>(to stream: inout T) {
        Swift.print("Version: \(version)", to: &stream)
        Swift.print("\(header.count) header entries", to: &stream)
        for (key,value) in header {
            Swift.print("\t\(key) = \(value)", to: &stream)
        }
        object.print(&stream,0)
    }
    
    public func toString() -> String {
        var s = ""
        print(to: &s)
        return s
    }
}

func legacyLogDecode(_ object : NSData) -> PlaygroundDecodedLogEntry? {
    return PlaygroundDecoder(BytesStorage(object)).decode()
}

// MARK: - LoggerDecoderImpl.swift

func * (lhs : String, rhs : Int) -> String {
    if (rhs <= 0) { return "" }
    if (rhs == 1) { return lhs }
    var str = lhs
    for _ in 1..<rhs
    {
        str += lhs
    }
    return str
}

protocol PlaygroundObjectDecoder {
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ kind: PlaygroundRepresentation) -> PlaygroundDecodedObject?
}

class PlaygroundDecodedObject_Structured: PlaygroundDecodedObject {
    let typeName: String
    let summary: String
    let totalCount: UInt64
    let storedCount: UInt64
    let type: String
    var children: [PlaygroundDecodedObject]

    init (_ name: String, _ brief: String, _ long: String, _ total: UInt64, _ stored: UInt64, _ type: String) {
        self.typeName = brief
        self.summary = long
        self.totalCount = total
        self.storedCount = stored
        self.children = [PlaygroundDecodedObject]()
        self.type = type
        super.init(name)
    }

    func addChild(_ x: PlaygroundDecodedObject) {
        self.children.append(x)
    }

    var count: Int { return children.count }

    subscript(x: Int) -> PlaygroundDecodedObject { return children[x] }

    override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
        let prefix = "\t"*depth
        super.print(&stream, depth)
        Swift.print("\(prefix)Typename: \(typeName)", to: &stream)
        Swift.print("\(prefix)Summary: \(summary)", to: &stream)
        Swift.print("\(prefix)Total count: \(totalCount)", to: &stream)
        Swift.print("\(prefix)Stored count: \(storedCount)", to: &stream)
        Swift.print("\(prefix)Type: \(type)", to: &stream)
        for child in children {
            child.print(&stream, depth+1)
        }
    }
}

class PlaygroundObjectDecoder_Structured: PlaygroundObjectDecoder {
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ kind: PlaygroundRepresentation) -> PlaygroundDecodedObject? {
        guard let brief = String(storage: bytes) else { return nil }
        guard let long = String(storage: bytes) else { return nil }
        guard let total = UInt64(storage: bytes) else { return nil }
        guard let stored: UInt64 = ((total > 0) ? UInt64(storage: bytes) : 0) else { return nil }
        let object = PlaygroundDecodedObject_Structured(name, brief, long, total, stored, kind.description)
        for _ in 0..<stored {
            object.addChild(decoder.decodeObject(bytes)!)
        }
        return object
    }
}

class PlaygroundDecodedObject_Gap: PlaygroundDecodedObject {
    override init(_ name: String) {
        super.init(name)
    }

    override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
        let prefix = "\t"*depth
        super.print(&stream, depth)
        Swift.print("\(prefix)Type: Gap", to: &stream)
    }
}

class PlaygroundObjectDecoder_Gap: PlaygroundObjectDecoder {
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ kind: PlaygroundRepresentation) -> PlaygroundDecodedObject? {
        return PlaygroundDecodedObject_Gap(name)
    }
}

class PlaygroundDecodedObject_ScopeEntry: PlaygroundDecodedObject {
    override init(_ name: String) {
        super.init(name)
    }

    override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
        let prefix = "\t"*depth
        super.print(&stream, depth)
        Swift.print("\(prefix)Type: Scope Entry", to: &stream)
    }
}

class PlaygroundObjectDecoder_ScopeEntry: PlaygroundObjectDecoder {
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ kind: PlaygroundRepresentation) -> PlaygroundDecodedObject? {
        return PlaygroundDecodedObject_ScopeEntry(name)
    }
}

class PlaygroundDecodedObject_ScopeExit: PlaygroundDecodedObject {
    override init(_ name: String) {
        super.init(name)
    }

    override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
        let prefix = "\t"*depth
        super.print(&stream, depth)
        Swift.print("\(prefix)Type: Scope Exit", to: &stream)
    }
}

class PlaygroundObjectDecoder_ScopeExit: PlaygroundObjectDecoder {
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ kind: PlaygroundRepresentation) -> PlaygroundDecodedObject? {
        return PlaygroundDecodedObject_ScopeExit(name)
    }
}

class PlaygroundDecodedObject_Error: PlaygroundDecodedObject {
    let error: String

    init(_ name: String, _ error: String) {
        self.error = error
        super.init(name)
    }

    override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
        let prefix = "\t"*depth
        super.print(&stream, depth)
        Swift.print("\(prefix)Type: Error", to: &stream)
        Swift.print("\(prefix)Message: \(error)", to: &stream)
    }
}

class PlaygroundObjectDecoder_Error: PlaygroundObjectDecoder {
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ kind: PlaygroundRepresentation) -> PlaygroundDecodedObject? {
        guard let message = String(storage: bytes) else { return nil }
        return PlaygroundDecodedObject_Error(name,message)
    }
}

class PlaygroundObjectDecoder_IDERepr: PlaygroundObjectDecoder {
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ kind: PlaygroundRepresentation) -> PlaygroundDecodedObject? {
        guard let preferSummary = Bool(storage: bytes) else { return nil }
        guard let brief = String(storage: bytes) else { return nil }
        guard let long = String(storage: bytes) else { return nil }
        guard let tag = String(storage: bytes) else { return nil }
        guard let size = UInt64(storage: bytes) else { return nil }
        let subset = bytes.subset(len: size, consume: true)
        return decoder.getIDEReprDecoder(tag).decodeObject(decoder, subset, name, preferSummary, brief, long, tag)
    }
}

protocol PlaygroundIDEReprDecoder {
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr?
}

class PlaygroundIDEReprDecoder_String: PlaygroundIDEReprDecoder {
    class PlaygroundDecodedObject_IDERepr_String: PlaygroundDecodedObject_IDERepr {
        let data: String

        init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String, _ data: String) {
            self.data = data
            super.init(name, psum, brief, long, tag)
        }

        override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
            let prefix = "\t"*depth
            super.print(&stream, depth)
            Swift.print("\(prefix)Data: \(data)", to: &stream)
        }

        override var payload: Any? { return data }
    }
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr? {
        guard let data = String(fullBytesStorage: bytes) else { return nil }
        return PlaygroundDecodedObject_IDERepr_String(name, psum ,brief, long, tag, data)
    }
}

class PlaygroundIDEReprDecoder_Int: PlaygroundIDEReprDecoder {
    class PlaygroundDecodedObject_IDERepr_Int: PlaygroundDecodedObject_IDERepr {
        let data: Int64

        init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String, _ data: Int64) {
            self.data = data
            super.init(name, psum, brief, long, tag)
        }

        override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
            let prefix = "\t"*depth
            super.print(&stream, depth)
            Swift.print("\(prefix)Data: \(data)", to: &stream)
        }

        override var payload: Any? { return data }
    }
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr? {
        guard let data = String(fullBytesStorage: bytes) else { return nil }
        guard let idata = Int(data) else { return nil }
        return PlaygroundDecodedObject_IDERepr_Int(name, psum ,brief, long, tag, Int64(idata))
    }
}

class PlaygroundIDEReprDecoder_UInt: PlaygroundIDEReprDecoder {
    class PlaygroundDecodedObject_IDERepr_UInt: PlaygroundDecodedObject_IDERepr {
        let data: UInt64

        init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String, _ data: UInt64) {
            self.data = data
            super.init(name, psum, brief, long, tag)
        }

        override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
            let prefix = "\t"*depth
            super.print(&stream, depth)
            Swift.print("\(prefix)Data: \(data)", to: &stream)
        }

        override var payload: Any? { return data }
    }
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr? {
        guard let data = String(fullBytesStorage: bytes) else { return nil }
        return PlaygroundDecodedObject_IDERepr_UInt(name, psum, brief, long, tag, strtoull(data, nil, 10))
    }
}

class PlaygroundIDEReprDecoder_Float: PlaygroundIDEReprDecoder {
    class PlaygroundDecodedObject_IDERepr_Float: PlaygroundDecodedObject_IDERepr {
        let data: Float

        init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String, _ data: Float) {
            self.data = data
            super.init(name, psum, brief, long, tag)
        }

        override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
            let prefix = "\t"*depth
            super.print(&stream, depth)
            Swift.print("\(prefix)Data: \(data)", to: &stream)
        }

        override var payload: Any? { return data }
    }
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr? {
        guard let data = Float(storage: bytes) else { return nil }
        return PlaygroundDecodedObject_IDERepr_Float(name, psum, brief, long, tag, data)
    }
}

class PlaygroundIDEReprDecoder_Double: PlaygroundIDEReprDecoder {
    class PlaygroundDecodedObject_IDERepr_Double: PlaygroundDecodedObject_IDERepr {
        let data: Double

        init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String, _ data: Double) {
            self.data = data
            super.init(name, psum, brief, long, tag)
        }

        override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
            let prefix = "\t"*depth
            super.print(&stream, depth)
            Swift.print("\(prefix)Data: \(data)", to: &stream)
        }

        override var payload: Any? { return data }
    }
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr? {
        guard let data = Double(storage: bytes) else { return nil }
        return PlaygroundDecodedObject_IDERepr_Double(name, psum, brief, long, tag, data)
    }
}

class PlaygroundIDEReprDecoder_Point: PlaygroundIDEReprDecoder {
    class PlaygroundDecodedObject_IDERepr_Point: PlaygroundDecodedObject_IDERepr {
        let data: CGPoint

        init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String, _ data: CGPoint) {
            self.data = data
            super.init(name, psum, brief, long, tag)
        }

        override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
            let prefix = "\t"*depth
            super.print(&stream, depth)
            Swift.print("\(prefix)Data: \(data)", to: &stream)
        }

        override var payload: Any? { return data }
    }
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr? {
        let decoder = LoggerUnarchiver(bytes)
        if !(decoder.has("x") && decoder.has("y")) { return nil }
        return PlaygroundDecodedObject_IDERepr_Point(name, psum, brief, long, tag, CGPoint(x: CGFloat(decoder.get(double: "x")), y: CGFloat(decoder.get(double: "y"))))
    }
}

class PlaygroundIDEReprDecoder_Size: PlaygroundIDEReprDecoder {
    class PlaygroundDecodedObject_IDERepr_Size: PlaygroundDecodedObject_IDERepr {
        let data: CGSize

        init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String, _ data: CGSize) {
            self.data = data
            super.init(name, psum, brief, long, tag)
        }

        override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
            let prefix = "\t"*depth
            super.print(&stream, depth)
            Swift.print("\(prefix)Data: \(data)", to: &stream)
        }

        override var payload: Any? { return data }
    }
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr? {
        let decoder = LoggerUnarchiver(bytes)
        if !(decoder.has("w") && decoder.has("h")) { return nil }
        return PlaygroundDecodedObject_IDERepr_Size(name, psum, brief, long, tag, CGSize(width: CGFloat(decoder.get(double: "w")), height: CGFloat(decoder.get(double: "h"))))
    }
}

class PlaygroundIDEReprDecoder_Rect: PlaygroundIDEReprDecoder {
    class PlaygroundDecodedObject_IDERepr_Rect: PlaygroundDecodedObject_IDERepr {
        let data: CGRect

        init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String, _ data: CGRect) {
            self.data = data
            super.init(name, psum, brief, long, tag)
        }

        override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
            let prefix = "\t"*depth
            super.print(&stream, depth)
            Swift.print("\(prefix)Data: \(data)", to: &stream)
        }

        override var payload: Any? { return data }
    }
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr? {
        let decoder = LoggerUnarchiver(bytes)
        if !(decoder.has("x") && decoder.has("y") && decoder.has("w") && decoder.has("h")) { return nil }
        return PlaygroundDecodedObject_IDERepr_Rect(name,
                                                    psum,
                                                    brief,
                                                    long,
                                                    tag,
                                                    CGRect(x: CGFloat(decoder.get(double: "x")),
                                                           y: CGFloat(decoder.get(double: "y")),
                                                           width: CGFloat(decoder.get(double:"w")),
                                                           height: CGFloat(decoder.get(double: "h"))))
    }
}

class PlaygroundIDEReprDecoder_Range: PlaygroundIDEReprDecoder {
    class PlaygroundDecodedObject_IDERepr_Range: PlaygroundDecodedObject_IDERepr {
        let data: NSRange

        init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String, _ data: NSRange) {
            self.data = data
            super.init(name, psum, brief, long, tag)
        }

        override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
            let prefix = "\t"*depth
            super.print(&stream, depth)
            Swift.print("\(prefix)Data: \(data)", to: &stream)
        }

        override var payload: Any? { return data }
    }
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr? {
        let decoder = LoggerUnarchiver(bytes)
        if !(decoder.has("loc") && decoder.has("len")) { return nil }
        return PlaygroundDecodedObject_IDERepr_Range(name, psum, brief, long, tag, NSRange(location: Int(decoder.get(int64: "loc")), length: Int(decoder.get(int64: "len"))))
    }
}

class PlaygroundIDEReprDecoder_Bool: PlaygroundIDEReprDecoder {
    class PlaygroundDecodedObject_IDERepr_Bool: PlaygroundDecodedObject_IDERepr {
        let data: Bool

        init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String, _ data: Bool) {
            self.data = data
            super.init(name, psum, brief, long, tag)
        }

        override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
            let prefix = "\t"*depth
            super.print(&stream, depth)
            Swift.print("\(prefix)Data: \(data)", to: &stream)
        }

        override var payload: Any? { return data }
    }
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr? {
        guard let data = Bool(storage: bytes) else { return nil }
        return PlaygroundDecodedObject_IDERepr_Bool(name, psum, brief, long, tag, data)
    }
}

class PlaygroundIDEReprDecoder_URL: PlaygroundIDEReprDecoder {
    class PlaygroundDecodedObject_IDERepr_URL: PlaygroundDecodedObject_IDERepr {
        let data: NSURL

        init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String, _ data: NSURL) {
            self.data = data
            super.init(name, psum, brief, long, tag)
        }

        override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
            let prefix = "\t"*depth
            super.print(&stream, depth)
            Swift.print("\(prefix)Data: \(data)", to: &stream)
        }

        override var payload: Any? { return data }
    }
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr? {
        guard let data = String(fullBytesStorage: bytes) else { return nil }
        guard let url = NSURL(string: data) else { return nil }
        return PlaygroundDecodedObject_IDERepr_URL(name, psum ,brief, long, tag, url)
    }
}

class PlaygroundIDEReprDecoder_Image: PlaygroundIDEReprDecoder {
    class PlaygroundDecodedObject_IDERepr_Image: PlaygroundDecodedObject_IDERepr {
        let data: ImageType
        
        init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String, _ data: ImageType) {
            self.data = data
            super.init(name, psum, brief, long, tag)
        }
        
        override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
            let prefix = "\t"*depth
            super.print(&stream, depth)
            Swift.print("\(prefix)Data: \(data)", to: &stream)
        }
        
        override var payload: Any? { return data }
    }
    func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr? {
        let data = bytes.data
        guard let image = ImageType(data: data as Data) else { return nil }
        return PlaygroundDecodedObject_IDERepr_Image(name, psum ,brief, long, tag, image)
    }
}

class PlaygroundDecoder {
    var bytes: BytesStorage
    var obj_decoders: [PlaygroundRepresentation: PlaygroundObjectDecoder]
    var iderepr_decoders: [String: PlaygroundIDEReprDecoder]

    init (_ bytes: BytesStorage) {
        self.bytes = bytes
        self.obj_decoders = [PlaygroundRepresentation: PlaygroundObjectDecoder]()
        self.iderepr_decoders = [String: PlaygroundIDEReprDecoder]()
        self.obj_decoders[.Class] = PlaygroundObjectDecoder_Structured()
        self.obj_decoders[.Struct] = PlaygroundObjectDecoder_Structured()
        self.obj_decoders[.Tuple] = PlaygroundObjectDecoder_Structured()
        self.obj_decoders[.Enum] = PlaygroundObjectDecoder_Structured()
        self.obj_decoders[.Aggregate] = PlaygroundObjectDecoder_Structured()
        self.obj_decoders[.Container] = PlaygroundObjectDecoder_Structured()
        self.obj_decoders[.IndexContainer] = PlaygroundObjectDecoder_Structured()
        self.obj_decoders[.KeyContainer] = PlaygroundObjectDecoder_Structured()
        self.obj_decoders[.MembershipContainer] = PlaygroundObjectDecoder_Structured()
        self.obj_decoders[.Gap] = PlaygroundObjectDecoder_Gap()
        self.obj_decoders[.ScopeEntry] = PlaygroundObjectDecoder_ScopeEntry()
        self.obj_decoders[.ScopeExit] = PlaygroundObjectDecoder_ScopeExit()
        self.obj_decoders[.Error] = PlaygroundObjectDecoder_Error()

        self.obj_decoders[.IDERepr] = PlaygroundObjectDecoder_IDERepr()
        self.iderepr_decoders["STRN"] = PlaygroundIDEReprDecoder_String()
        self.iderepr_decoders["SINT"] = PlaygroundIDEReprDecoder_Int()
        self.iderepr_decoders["UINT"] = PlaygroundIDEReprDecoder_UInt()
        self.iderepr_decoders["FLOT"] = PlaygroundIDEReprDecoder_Float()
        self.iderepr_decoders["DOBL"] = PlaygroundIDEReprDecoder_Double()
        self.iderepr_decoders["RECT"] = PlaygroundIDEReprDecoder_Rect()
        self.iderepr_decoders["PONT"] = PlaygroundIDEReprDecoder_Point()
        self.iderepr_decoders["SIZE"] = PlaygroundIDEReprDecoder_Size()
        self.iderepr_decoders["RANG"] = PlaygroundIDEReprDecoder_Range()
        self.iderepr_decoders["BOOL"] = PlaygroundIDEReprDecoder_Bool()
        self.iderepr_decoders["URL"]  = PlaygroundIDEReprDecoder_URL()
        self.iderepr_decoders["IMAG"]  = PlaygroundIDEReprDecoder_Image()
        self.iderepr_decoders["VIEW"]  = PlaygroundIDEReprDecoder_Image()
        self.iderepr_decoders["SKIT"]  = PlaygroundIDEReprDecoder_Image()
    }

    func getIDEReprDecoder(_ tag: String) -> PlaygroundIDEReprDecoder {
        if let decoder = iderepr_decoders[tag] {
            return decoder
        }
        class DefaultIDEReprDecoder: PlaygroundIDEReprDecoder {
            class DefaultIDEReprDecoder_Object: PlaygroundDecodedObject_IDERepr {
                let data: String

                init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String, _ data: String) {
                    self.data = data
                    super.init(name, psum, brief, long, tag)
                }

            }
            func decodeObject(_ decoder: PlaygroundDecoder, _ bytes: BytesStorage, _ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) -> PlaygroundDecodedObject_IDERepr? {
                let len_to_dump = 128
                var buffer = ""
                for i in 0..<bytes.count {
                    if i > len_to_dump {
                        buffer += "..."
                        break
                    } else {
                        buffer = buffer + "\(bytes.get()) "
                    }
                }
                return DefaultIDEReprDecoder_Object(name, psum, brief, long, tag, buffer)
            }
        }
        return DefaultIDEReprDecoder()
    }

    func decodeObject(_ bytes: BytesStorage) -> PlaygroundDecodedObject? {
        guard let name = String(storage: bytes) else { return nil }
        let kind = PlaygroundRepresentation(byte: bytes.get())
        return obj_decoders[kind]?.decodeObject(self, bytes, name, kind)
    }

    func decode () -> PlaygroundDecodedLogEntry? {
        guard let version = UInt64(storage: bytes) else { return nil }
        guard let startline = UInt64(eightBytesStorage: bytes) else { return nil }
        guard let startcol = UInt64(eightBytesStorage: bytes) else { return nil }
        guard let endline = UInt64(eightBytesStorage: bytes) else { return nil }
        guard let endcol = UInt64(eightBytesStorage: bytes) else { return nil }
        guard let header_count = UInt64(storage: bytes) else { return nil }
        var header = [String: String]()
        for _ in 0..<header_count {
            guard let key = String(storage: bytes) else { return nil }
            guard let value = String(storage: bytes) else { return nil }
            header[key] = value
        }
        guard let object = decodeObject(self.bytes) else { return nil }
        return PlaygroundDecodedLogEntry(version: version,
                                         startLine: startline,
                                         startColumn: startcol,
                                         endLine: endline,
                                         endColumn: endcol,
                                         header: header,
                                         object: object)
    }
}

class PlaygroundDecodedObject {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
        let prefix = "\t"*depth
        Swift.print("\(prefix)Name: \(name)", to: &stream)
    }
}

class PlaygroundDecodedObject_IDERepr: PlaygroundDecodedObject {
    let shouldPreferSummary: Bool
    let typeName: String
    let summary: String
    let tag: String

    init (_ name: String, _ psum: Bool, _ brief: String, _ long: String, _ tag: String) {
        self.shouldPreferSummary = psum
        self.typeName = brief
        self.summary = long
        self.tag = tag
        super.init(name)
    }

    override func print<T: TextOutputStream>(_ stream: inout T, _ depth: Int) {
        let prefix = "\t"*depth
        super.print(&stream, depth)
        Swift.print("\(prefix)Typename: \(typeName)", to: &stream)
        Swift.print("\(prefix)Summary: \(summary)", to: &stream)
        Swift.print("\(prefix)Tag: \(tag)", to: &stream)
    }

    var payload: Any? { return nil }
}
