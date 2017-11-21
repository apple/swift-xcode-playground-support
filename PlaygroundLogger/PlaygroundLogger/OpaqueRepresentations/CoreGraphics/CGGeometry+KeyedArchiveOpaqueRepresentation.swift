//===--- CGGeometry+KeyedArchiveOpaqueRepresentation.swift ----------------===//
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

import CoreGraphics
import Foundation

fileprivate let pointTag = "PONT"
fileprivate let sizeTag = "SIZE"
fileprivate let rectTag = "RECT"

extension CGPoint: KeyedArchiveOpaqueRepresentation {
    var tag: String { return pointTag }
    
    func encodeOpaqueRepresentation(with encoder: NSCoder, usingFormat format: LogEncoder.Format) {
        encoder.encode(Double(self.x), forKey: "x")
        encoder.encode(Double(self.y), forKey: "y")
    }
}

extension CGSize: KeyedArchiveOpaqueRepresentation {
    var tag: String { return sizeTag }
    
    func encodeOpaqueRepresentation(with encoder: NSCoder, usingFormat format: LogEncoder.Format) {
        encoder.encode(Double(self.width), forKey: "w")
        encoder.encode(Double(self.height), forKey: "h")
    }
}

extension CGRect: KeyedArchiveOpaqueRepresentation {
    var tag: String { return rectTag }
    
    func encodeOpaqueRepresentation(with encoder: NSCoder, usingFormat format: LogEncoder.Format) {
        encoder.encode(Double(self.origin.x), forKey: "x")
        encoder.encode(Double(self.origin.y), forKey: "y")
        encoder.encode(Double(self.size.width), forKey: "w")
        encoder.encode(Double(self.size.height), forKey: "h")
    }
}
