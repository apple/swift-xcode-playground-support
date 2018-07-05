//===--- CGImage+OpaqueImageRepresentable.swift ---------------------------===//
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

import CoreGraphics

#if os(macOS)
    import AppKit
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif

extension CGImage: OpaqueImageRepresentable {
    func encodeImage(into encoder: LogEncoder, withFormat format: LogEncoder.Format) throws {
        #if os(macOS)
            // On macOS, simply create an NSBitmapImageRep with the receiver and use that.
            let bitmapRep = NSBitmapImageRep(cgImage: self)
            try bitmapRep.encodeImage(into: encoder, withFormat: format)
        #elseif os(iOS) || os(tvOS)
            let uiImage = UIImage(cgImage: self)
            try uiImage.encodeImage(into: encoder, withFormat: format)
        #endif
    }
}
