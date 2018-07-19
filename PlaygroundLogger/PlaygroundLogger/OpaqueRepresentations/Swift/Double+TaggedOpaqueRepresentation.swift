//===--- Double+TaggedOpaqueRepresentation.swift --------------------------===//
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

fileprivate let doubleTag = "DOBL"

extension Double: TaggedOpaqueRepresentation {
    var tag: String { return doubleTag }
    
    func encodePayload(into encoder: LogEncoder, usingFormat format: LogEncoder.Format) {
        encoder.encode(number: UInt64(MemoryLayout<Double>.size))
        encoder.encode(double: self)
    }
}
