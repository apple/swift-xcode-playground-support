//===--- Int64+TaggedOpaqueRepresentation.swift ---------------------------===//
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

fileprivate let signedIntegerTag = "SINT"

extension Int64: TaggedOpaqueRepresentation {
    var tag: String { return signedIntegerTag }
    
    func encodePayload(into encoder: LogEncoder, usingFormat format: LogEncoder.Format) {
        let description = String(self)
        let utf8Count = description.utf8.count
        encoder.encode(number: UInt64(utf8Count))
        encoder.encode(bytes: description, length: utf8Count)
    }
}
