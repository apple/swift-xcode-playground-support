//===--- LogPacket+Encoding.swift -----------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2017-2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation

extension LogPacket {
    func encode(inFormat format: LogEncoder.Format = .current) throws -> Data {
        let encoder = LogEncoder()
        
        // Encode the format version.
        encoder.encode(number: format.rawValue)
        
        // Encode the source location.
        encoder.encode(number: UInt64(startLine), allowShortEncoding: false)
        encoder.encode(number: UInt64(startColumn), allowShortEncoding: false)
        encoder.encode(number: UInt64(endLine), allowShortEncoding: false)
        encoder.encode(number: UInt64(endColumn), allowShortEncoding: false)
        
        // Encode the thread ID.
        encoder.encode(number: 1)
        encoder.encode(string: "tid")
        encoder.encode(string: threadID)
        
        // Encode our top-level log entry. (This will add any child entries automatically.)
        try logEntry.encode(with: encoder, format: format)
        
        return encoder.encodedData
    }
}
