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
    
    func encode(with encoder: LogEncoder, format: LogEncoder.Format) throws {
        // Start by encoding the name of the log entry.
        encoder.encode(string: name)
        
        // Then encode the type code for the log entry.
        encoder.encode(byte: typeCode.rawValue)
        
        // Finally, encode the entry-type-specific information.
        switch self {
        case let.structured(_, typeName, summary, totalChildrenCount, children, _):
            try LogEntry.encode(structuredWithTypeName: typeName, summary: summary, totalChildrenCount: totalChildrenCount, children: children, into: encoder, usingFormat: format)
        case let .opaque(_, typeName, summary, preferBriefSummary, representation):
            try LogEntry.encode(opaqueWithTypeName: typeName, summary: summary, preferBriefSummary: preferBriefSummary, representation: representation, into: encoder, usingFormat: format)
        case .gap, .scopeEntry, .scopeExit:
            // Gap, scope entry, and scope exit entries contain no additional data beyond what's common to all log entry types.
            break
        case let .error(reason):
            LogEntry.encode(errorWithReason: reason, into: encoder)
        }
    }
    
    private static func encode(structuredWithTypeName typeName: String, summary: String, totalChildrenCount: Int, children: [LogEntry], into encoder: LogEncoder, usingFormat format: LogEncoder.Format) throws {
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
        try children.forEach { try $0.encode(with: encoder, format: format) }
    }
    
    private static func encode(opaqueWithTypeName typeName: String, summary: String, preferBriefSummary: Bool, representation: LogEntry.OpaqueRepresentation, into encoder: LogEncoder, usingFormat format: LogEncoder.Format) throws {
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

        try representation.encode(into: encoder, usingFormat: format)
    }
    
    private static func encode(errorWithReason reason: String, into encoder: LogEncoder) {
        // Error entries are just the reason string, which may be empty.
        encoder.encode(string: reason)
    }
}
