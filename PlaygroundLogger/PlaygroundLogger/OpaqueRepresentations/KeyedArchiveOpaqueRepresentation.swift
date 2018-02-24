//===--- KeyedArchiveOpaqueRepresentation.swift ---------------------------===//
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

protocol KeyedArchiveOpaqueRepresentation: TaggedOpaqueRepresentation {
    func encodeOpaqueRepresentation(with encoder: NSCoder, usingFormat format: LogEncoder.Format) throws
}

extension KeyedArchiveOpaqueRepresentation {
    func encodePayload(into encoder: LogEncoder, usingFormat format: LogEncoder.Format) throws {
        let archivedData = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: archivedData)
        
        try self.encodeOpaqueRepresentation(with: archiver, usingFormat: format)
        
        archiver.finishEncoding()

        encoder.encode(number: UInt64(archivedData.length))
        encoder.encode(data: archivedData as Data)
    }
}
