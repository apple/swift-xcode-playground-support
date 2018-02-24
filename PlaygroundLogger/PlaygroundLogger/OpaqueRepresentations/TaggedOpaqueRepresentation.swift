//===--- TaggedOpaqueRepresentation.swift ---------------------------------===//
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

protocol TaggedOpaqueRepresentation: LogEntry.OpaqueRepresentation {
    var tag: String { get }
    
    func encodePayload(into encoder: LogEncoder, usingFormat format: LogEncoder.Format) throws
}

extension TaggedOpaqueRepresentation {
    func encode(into encoder: LogEncoder, usingFormat format: LogEncoder.Format) throws {
        encoder.encode(string: tag)
        try self.encodePayload(into: encoder, usingFormat: format)
    }
}
