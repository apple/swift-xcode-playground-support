//===--- CIImage+CustomOpaqueLoggable.swift -------------------------------===//
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

import CoreImage
import CoreGraphics

#if os(macOS)
    import AppKit
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif

extension CIImage: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        if #available(macOS 10.12, *), let cgImage = self.cgImage {
            return ImageOpaqueRepresentation(kind: .image, backedBy: cgImage)
        }
        else {
            #if os(macOS)
                let imageRep = NSCIImageRep(ciImage: self)
                let image = NSImage(size: imageRep.size)
                image.addRepresentation(imageRep)
            #elseif os(iOS) || os(tvOS)
                let image = UIImage(ciImage: self)
            #endif
            
            return ImageOpaqueRepresentation(kind: .image, backedBy: image)
        }
    }
}
