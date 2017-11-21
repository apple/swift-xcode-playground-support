//===--- NSRange+KeyedArchiveOpaqueRepresentation.swift -------------------===//
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

fileprivate let rangeTag = "RANG"

extension NSRange: KeyedArchiveOpaqueRepresentation {
    var tag: String { return rangeTag }
    
    func encodeOpaqueRepresentation(with encoder: NSCoder, usingFormat format: LogEncoder.Format) {
        encoder.encode(Int64(self.location), forKey: "loc")
        encoder.encode(Int64(self.length), forKey: "len")
    }
}
