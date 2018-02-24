//===--- ImageOpaqueRepresentation.swift ----------------------------------===//
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

protocol OpaqueImageRepresentable {
    func encodeImage(into encoder: LogEncoder, withFormat format: LogEncoder.Format) throws
}

struct ImageOpaqueRepresentation: TaggedOpaqueRepresentation {
    enum Kind: String {
        case image = "IMAG"
        case view = "VIEW"
        case sprite = "SKIT"
    }
    
    private let kind: Kind
    private let imageEncoder: (LogEncoder, LogEncoder.Format) throws -> Void
    
    init<Implementation: OpaqueImageRepresentable>(kind: Kind, backedBy implementation: Implementation) {
        self.kind = kind
        self.imageEncoder = { try implementation.encodeImage(into: $0, withFormat: $1) }
    }
    
    var tag: String { return kind.rawValue }
    
    func encodePayload(into encoder: LogEncoder, usingFormat format: LogEncoder.Format) throws {
        try imageEncoder(encoder, format)
    }
}
