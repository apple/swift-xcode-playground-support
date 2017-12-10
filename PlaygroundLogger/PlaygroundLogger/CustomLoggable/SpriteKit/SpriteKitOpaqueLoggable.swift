//===--- SpriteKitOpaqueLoggable.swift ------------------------------------===//
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

import SpriteKit

@objc fileprivate class SpriteKitCopyImageDataHook: NSObject {
    @objc(_copyImageData) func _copyImageData() -> Data? {
        fatalError("This stub _copyImageData should not be called!")
    }
}

fileprivate protocol SpriteKitOpaqueLoggable: class, OpaqueImageRepresentable, CustomOpaqueLoggable {}

extension SpriteKitOpaqueLoggable {
    func encodeImage(into encoder: LogEncoder, withFormat format: LogEncoder.Format) {
        guard let copyImageDataMethod = (self as AnyObject)._copyImageData, let imageData = copyImageDataMethod() else {
            // TODO: don't crash in this case
            fatalError("Unable to get image data, unable to encode anything")
        }
        
        _ = imageData
        
        unimplemented()
    }
    
    var opaqueRepresentation: LogEntry.OpaqueRepresentation {
        return ImageOpaqueRepresentation(kind: .sprite, backedBy: self)
    }
}

extension SKShapeNode: SpriteKitOpaqueLoggable {}
extension SKSpriteNode: SpriteKitOpaqueLoggable {}
extension SKTextureAtlas: SpriteKitOpaqueLoggable {}
extension SKTexture: SpriteKitOpaqueLoggable {}
