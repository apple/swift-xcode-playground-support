//===--- LogEntry+Encoding.swift ------------------------------------------===//
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

import Foundation

extension LogEntry {
    private enum TypeCode: UInt8 {
        case `class` = 1
        case `struct` = 2
        case tuple = 3
        case `enum` = 4
        case aggregate = 5
        case container = 6
        case opaque = 7
        case gap = 8
        case scopeEntry = 9
        case scopeExit = 10
        case error = 11
        case indexContainer = 12
        case keyContainer = 13
        case membershipContainer = 14
    }
    
    private var typeCode: TypeCode {
        switch self {
        case let .structured(_, _, _, _, _, disposition):
            switch disposition {
            case .`class`:
                return .`class`
            case .`struct`:
                return .`struct`
            case .tuple:
                return .tuple
            case .`enum`:
                return .`enum`
            case .aggregate:
                return .aggregate
            case .container:
                return .container
            case .indexContainer:
                return .indexContainer
            case .keyContainer:
                return .keyContainer
            case .membershipContainer:
                return .membershipContainer
            }
        case .opaque:
            return .opaque
        case .gap:
            return .gap
        case .scopeEntry:
            return .scopeEntry
        case .scopeExit:
            return .scopeExit
        case .error:
            return .error
        }
    }
    
    func encode(with encoder: LogEncoder, format: LogEncoder.Format) {
        // Start by encoding the name of the log entry.
        encoder.encode(string: name)
        
        // Then encode the type code for the log entry.
        encoder.encode(byte: typeCode.rawValue)
        
        // Finally, encode the entry-type-specific information.
        switch self {
        case let.structured(_, typeName, summary, totalChildrenCount, children, _):
            LogEntry.encode(structuredWithTypeName: typeName, summary: summary, totalChildrenCount: totalChildrenCount, children: children, into: encoder, usingFormat: format)
        case let .opaque(_, typeName, summary, preferBriefSummary, representation):
            LogEntry.encode(opaqueWithTypeName: typeName, summary: summary, preferBriefSummary: preferBriefSummary, representation: representation, into: encoder, usingFormat: format)
        case .gap, .scopeEntry, .scopeExit:
            // Gap, scope entry, and scope exit entries contain no additional data beyond what's common to all log entry types.
            break
        case let .error(reason):
            LogEntry.encode(errorWithReason: reason, into: encoder)
        }
    }
    
    private static func encode(structuredWithTypeName typeName: String, summary: String, totalChildrenCount: Int, children: [LogEntry], into encoder: LogEncoder, usingFormat format: LogEncoder.Format) {
        // Structured entries contain the following type-specific information:
        //   - Type name, encoded as a string
        //   - Summary, encoded as a string
        //   - Total children count, encoded as a number
        //   - Logged children count, encoded as a number
        //   - Log entries for children
        // "Logged children count" is omitted if "total children count" is zero.
        
        encoder.encode(string: typeName)
        encoder.encode(string: summary)
        encoder.encode(number: UInt64(totalChildrenCount))
        
        guard totalChildrenCount > 0 else { return }
        
        encoder.encode(number: UInt64(children.count))
        children.forEach { $0.encode(with: encoder, format: format) }
    }
    
    private static func encode(opaqueWithTypeName typeName: String, summary: String, preferBriefSummary: Bool, representation: OpaqueRepresentation, into encoder: LogEncoder, usingFormat format: LogEncoder.Format) {
        // Opaque entries contain the following type-specific information:
        //   - Prefers brief summary, encoded as a boolean
        //   - Type name, encoded as a string
        //   - Summary, encoded as a string
        //   - Tag, encoded as a string
        //   - Payload byte count, encoded as a number
        //   - Payload, encoded as raw bytes (format specified by tag)
        // Encoding the tag, payload byte count, and payload is handled by `LogEntry.OpaqueRepresentation.encode(into:usingFormat:)`.
        
        encoder.encode(boolean: preferBriefSummary)
        encoder.encode(string: typeName)
        encoder.encode(string: summary)
        representation.encode(into: encoder, usingFormat: format)
    }
    
    private static func encode(errorWithReason reason: String, into encoder: LogEncoder) {
        // Error entries are just the reason string, which may be empty.
        encoder.encode(string: reason)
    }
}

extension LogEntry.OpaqueRepresentation {
    private enum Tag: String {
        case string = "STRN"
        case signedInteger = "SINT"
        case unsignedInteger = "UINT"
        case float = "FLOT"
        case double = "DOBL"
        case boolean = "BOOL"
        case image = "IMAG"
        case view = "VIEW"
        case sprite = "SKIT"
        case color = "COLR"
        case bezierPath = "BEZP"
        case attributedString = "ASTR"
        case point = "PONT"
        case size = "SIZE"
        case rect = "RECT"
        case nsRange = "RANG"
        case url = "URL"
    }
    
    private var tag: Tag {
        switch self {
        case .string:
            return .string
        case .signedInteger:
            return .signedInteger
        case .unsignedInteger:
            return .unsignedInteger
        case .float:
            return .float
        case .double:
            return .double
        case .boolean:
            return .boolean
        case .image:
            return .image
        case .view:
            return .view
        case .sprite:
            return .sprite
        case .color:
            return .color
        case .bezierPath:
            return .bezierPath
        case .attributedString:
            return .attributedString
        case .point:
            return .point
        case .size:
            return .size
        case .rect:
            return .rect
        case .nsRange:
            return .nsRange
        case .url:
            return .url
        }
    }
    
    fileprivate func encode(into encoder: LogEncoder, usingFormat format: LogEncoder.Format) {
        // Opaque representations are encoded as follows:
        //   - Tag, encoded as a string
        //   - Payload byte count, encoded as a number
        //   - Payload, encoded as raw bytes (format specified by tag)
        
        encoder.encode(string: tag.rawValue)
        
        let encodingFunction: () -> Void
        
        switch self {
        case let .string(string):
            encodingFunction = {
                let utf8Count = string.utf8.count
                encoder.encode(number: UInt64(utf8Count))
                encoder.encode(bytes: string, length: utf8Count)
            }
        case let .signedInteger(integer):
            encodingFunction = {
                let stringRepresentation = String(integer)
                let utf8Count = stringRepresentation.utf8.count
                encoder.encode(number: UInt64(utf8Count))
                encoder.encode(bytes: stringRepresentation, length: utf8Count)
            }
        case let .unsignedInteger(integer):
            encodingFunction = {
                let stringRepresentation = String(integer)
                let utf8Count = stringRepresentation.utf8.count
                encoder.encode(number: UInt64(utf8Count))
                encoder.encode(bytes: stringRepresentation, length: utf8Count)
            }
        case let .float(float):
            encodingFunction = {
                encoder.encode(number: UInt64(MemoryLayout<Float>.size))
                encoder.encode(float: float)
            }
        case let .double(double):
            encodingFunction = {
                encoder.encode(number: UInt64(MemoryLayout<Double>.size))
                encoder.encode(double: double)
            }
        case let .boolean(boolean):
            encodingFunction = {
                encoder.encode(number: 1)
                encoder.encode(boolean: boolean)
            }
        case let .image(image), let .sprite(image):
            _ = image
            fatalError("Image-based encoding not yet supported")
        case let .view(view):
            _ = view
            fatalError("View-based encoding not yet supported")
        case let .color(color):
            guard let colorSpace = color.colorSpace else {
                // TODO: figure out how to handle this case
                fatalError("Colors without a color space cannot currently be logged")
            }
            
            guard colorSpace.model != .pattern else {
                // TODO: encode image of pattern
                // TODO: make this not encode an image of pattern but encode the pattern for round-tripping (in a future format version)
                fatalError("Pattern colors cannot currently be logged")
            }
            
            guard let colorSpaceName = colorSpace.name else {
                fatalError("Colors whose color space is unnamed cannot currently be logged")
            }
            
            guard let components = color.components else {
                fatalError("Colors whose components cannot be fetched cannot currently be logged")
            }
            
            encodingFunction = {
                let archivedData = NSMutableData()
                let archiver = NSKeyedArchiver(forWritingWith: archivedData)
                archiver.encode(colorSpaceName as String, forKey: "IDEColorSpaceKey")
                archiver.encode(components.map { $0 as NSNumber }, forKey: "IDEColorComponentsKey")
                archiver.finishEncoding()
                encoder.encode(data: archivedData as Data)
            }
        // TODO: make this exception-safe
        case let .bezierPath(bezierPath):
            // TODO: is this OK cross-platform?
            encodingFunction = {
                let archivedData = NSMutableData()
                let archiver = NSKeyedArchiver(forWritingWith: archivedData)
                archiver.encode(bezierPath, forKey: "root")
                archiver.finishEncoding()
                encoder.encode(data: archivedData as Data)
            }
        case let .attributedString(attributedString):
            encodingFunction = {
                let archivedData = NSMutableData()
                let archiver = NSKeyedArchiver(forWritingWith: archivedData)
                archiver.encode(attributedString, forKey: "root")
                archiver.finishEncoding()
                encoder.encode(data: archivedData as Data)
            }
        case let .point(point):
            encodingFunction = {
                let archivedData = NSMutableData()
                let archiver = NSKeyedArchiver(forWritingWith: archivedData)
                archiver.encode(Double(point.x), forKey: "x")
                archiver.encode(Double(point.y), forKey: "y")
                archiver.finishEncoding()
                encoder.encode(data: archivedData as Data)
            }
        case let .size(size):
            encodingFunction = {
                let archivedData = NSMutableData()
                let archiver = NSKeyedArchiver(forWritingWith: archivedData)
                archiver.encode(Double(size.width), forKey: "w")
                archiver.encode(Double(size.height), forKey: "h")
                archiver.finishEncoding()
                encoder.encode(data: archivedData as Data)
            }
        case let .rect(rect):
            encodingFunction = {
                let archivedData = NSMutableData()
                let archiver = NSKeyedArchiver(forWritingWith: archivedData)
                archiver.encode(Double(rect.origin.x), forKey: "x")
                archiver.encode(Double(rect.origin.y), forKey: "y")
                archiver.encode(Double(rect.size.width), forKey: "w")
                archiver.encode(Double(rect.size.height), forKey: "h")
                archiver.finishEncoding()
                encoder.encode(data: archivedData as Data)
            }
        case let .nsRange(range):
            encodingFunction = {
                let archivedData = NSMutableData()
                let archiver = NSKeyedArchiver(forWritingWith: archivedData)
                archiver.encode(Int64(range.location), forKey: "loc")
                archiver.encode(Int64(range.length), forKey: "len")
                archiver.finishEncoding()
                encoder.encode(data: archivedData as Data)
            }
        case let .url(url):
            encodingFunction = {
                let absoluteString = url.absoluteString
                let utf8Count = absoluteString.utf8.count
                encoder.encode(number: UInt64(utf8Count))
                encoder.encode(bytes: absoluteString, length: utf8Count)
            }
        }
        
        encodingFunction()
    }
}
