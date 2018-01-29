//===--- UIKit.swift --------------------------------------------------===//
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

#if os(iOS) || os(tvOS)
    
import UIKit

fileprivate var quickLookViews = Set<UIView>()

extension UIView : _DefaultCustomPlaygroundQuickLookable {
    public var _defaultCustomPlaygroundQuickLook: PlaygroundQuickLook {
        if quickLookViews.contains(self) {
            return .view(UIImage())
        } else {
            quickLookViews.insert(self)
            // in case of an empty rectangle abort the logging
            if (bounds.size.width == 0) || (bounds.size.height == 0) {
                return .view(UIImage())
            }
            
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
            // UIKit is about to update this to be optional, so make it work
            // with both older and newer SDKs. (In this context it should always
            // be present.)
            let ctx: CGContext! = UIGraphicsGetCurrentContext()
            UIColor(white:1.0, alpha:0.0).set()
            ctx.fill(bounds)
            layer.render(in: ctx)
            
            let image: UIImage! = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            quickLookViews.remove(self)
            return .view(image)
        }
    }
}

#endif
