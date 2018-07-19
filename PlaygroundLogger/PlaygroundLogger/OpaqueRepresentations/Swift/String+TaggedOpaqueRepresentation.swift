//===--- String+TaggedOpaqueRepresentation.swift --------------------------===//
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

fileprivate let stringTag = "STRN"

extension String: TaggedOpaqueRepresentation {
    var tag: String { return stringTag }
    
    func encodePayload(into encoder: LogEncoder, usingFormat format: LogEncoder.Format) {
        let utf8Count = self.utf8.count
        encoder.encode(number: UInt64(utf8Count))
        encoder.encode(bytes: self, length: utf8Count)
    }
}
