//===--- NSBezierPath+KeyedArchiveOpaqueRepresentation.swift --------------===//
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

#if os(iOS) || os(tvOS)
    import Foundation
    import UIKit
    
    fileprivate let bezierPathTag = "BEZP"
    
    extension UIBezierPath: KeyedArchiveOpaqueRepresentation {
        var tag: String { return bezierPathTag }
        
        func encodeOpaqueRepresentation(with encoder: NSCoder, usingFormat format: LogEncoder.Format) {
            encoder.encode(self, forKey: "root")
        }
    }
#endif

