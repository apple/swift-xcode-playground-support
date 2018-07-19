//===--- Bool+TaggedOpaqueRepresentation.swift ----------------------------===//
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

fileprivate let boolTag = "BOOL"

extension Bool: TaggedOpaqueRepresentation {
    var tag: String { return boolTag }
    
    func encodePayload(into encoder: LogEncoder, usingFormat format: LogEncoder.Format) {
        encoder.encode(number: 1)
        encoder.encode(boolean: self)
    }
}
