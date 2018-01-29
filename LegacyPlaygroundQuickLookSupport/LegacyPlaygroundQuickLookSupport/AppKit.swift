//===--- AppKit.swift -----------------------------------------------------===//
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

#if os(macOS)

import AppKit

extension NSCursor : _DefaultCustomPlaygroundQuickLookable {
    public var _defaultCustomPlaygroundQuickLook: PlaygroundQuickLook {
        return .image(image)
    }
}

fileprivate var quickLookViews = Set<NSView>()

extension NSView : _DefaultCustomPlaygroundQuickLookable {
    public var _defaultCustomPlaygroundQuickLook: PlaygroundQuickLook {
        // if you set NSView.needsDisplay, you can get yourself in a recursive scenario where the same view
        // could need to draw itself in order to get a QLObject for itself, which in turn if your code was
        // instrumented to log on-draw, would cause yourself to get back here and so on and so forth
        // until you run out of stack and crash
        // This code checks that we aren't trying to log the same view recursively - and if so just returns
        // an empty view, which is probably a safer option than crashing
        // FIXME: is there a way to say "cacheDisplayInRect butDoNotRedrawEvenIfISaidSo"?
        if quickLookViews.contains(self) {
            return .view(NSImage())
        } else {
            quickLookViews.insert(self)
            let result: PlaygroundQuickLook
            if let b = bitmapImageRepForCachingDisplay(in: bounds) {
                cacheDisplay(in: bounds, to: b)
                result = .view(b)
            } else {
                result = .view(NSImage())
            }
            quickLookViews.remove(self)
            return result
        }
    }
}

    
#endif
