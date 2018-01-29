//===--- SpriteKit.swift --------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014-2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import SpriteKit

// this class only exists to allow AnyObject lookup of _copyImageData
// since that method only exists in a private header in SpriteKit, the lookup
// mechanism by default fails to accept it as a valid AnyObject call
@objc fileprivate class _SpriteKitMethodProvider: NSObject {
    override init() { _sanityCheckFailure("don't touch me") }
    @objc func _copyImageData() -> NSData! { return nil }
}

extension SKShapeNode: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        let data = (self as AnyObject)._copyImageData?() as Data?
        
        // we could send a Raw, but I don't want to make a copy of the
        // bytes for no good reason make an NSImage out of them and
        // send that
        #if os(macOS)
            let image = data.flatMap(NSImage.init(data:)) ?? NSImage()
        #elseif os(iOS) || os(watchOS) || os(tvOS)
            let image = data.flatMap(UIImage.init(data:)) ?? UIImage()
        #endif
        
        return .sprite(image)
    }
}

extension SKSpriteNode: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        let data = (self as AnyObject)._copyImageData?() as Data?
        
        // we could send a Raw, but I don't want to make a copy of the
        // bytes for no good reason make an NSImage out of them and
        // send that
        #if os(macOS)
            let image = data.flatMap(NSImage.init(data:)) ?? NSImage()
        #elseif os(iOS) || os(watchOS) || os(tvOS)
            let image = data.flatMap(UIImage.init(data:)) ?? UIImage()
        #endif
        
        return .sprite(image)
    }
}

extension SKTextureAtlas: CustomPlaygroundQuickLookable {
  public var customPlaygroundQuickLook: PlaygroundQuickLook {
    let data = (self as AnyObject)._copyImageData?() as Data?

    // we could send a Raw, but I don't want to make a copy of the
    // bytes for no good reason make an NSImage out of them and
    // send that
#if os(macOS)
    let image = data.flatMap(NSImage.init(data:)) ?? NSImage()
#elseif os(iOS) || os(watchOS) || os(tvOS)
    let image = data.flatMap(UIImage.init(data:)) ?? UIImage()
#endif

    return .sprite(image)
  }
}

extension SKTexture: CustomPlaygroundQuickLookable {
  public var customPlaygroundQuickLook: PlaygroundQuickLook {
    let data = (self as AnyObject)._copyImageData?() as Data?

    // we could send a Raw, but I don't want to make a copy of the
    // bytes for no good reason make an NSImage out of them and
    // send that
#if os(macOS)
    let image = data.flatMap(NSImage.init(data:)) ?? NSImage()
#elseif os(iOS) || os(watchOS) || os(tvOS)
    let image = data.flatMap(UIImage.init(data:)) ?? UIImage()
#endif

    return .sprite(image)
  }
}

