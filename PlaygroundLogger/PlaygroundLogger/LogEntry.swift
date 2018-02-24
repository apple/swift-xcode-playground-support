//===--- LogEntry.swift ---------------------------------------------------===//
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

enum LogEntry {
    typealias OpaqueRepresentation = OpaqueLogEntryRepresentation
    
    enum StructuredDisposition {
        case `class`
        case `struct`
        case tuple
        case `enum`
        case aggregate
        case container
        case indexContainer
        case keyContainer
        case membershipContainer
    }
    
    case structured(name: String, typeName: String, summary: String, totalChildrenCount: Int, children: [LogEntry], disposition: StructuredDisposition)
    case opaque(name: String, typeName: String, summary: String, preferBriefSummary: Bool, representation: OpaqueRepresentation)
    case gap
    case scopeEntry, scopeExit
    case error(reason: String)
}

protocol OpaqueLogEntryRepresentation {
    func encode(into encoder: LogEncoder, usingFormat format: LogEncoder.Format) throws
}

private let emptyName = ""

extension LogEntry {
    var name: String {
        switch self {
        case let .structured(name, _, _, _, _, _):
            return name
        case let .opaque(name, _, _, _, _):
            return name
        case .gap, .scopeEntry, .scopeExit, .error:
            return emptyName
        }
    }
}
