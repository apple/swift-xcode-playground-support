//===--- PlaygroundQuickLook.swift ----------------------------------------===//
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

import Foundation

#if os(macOS)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

import CoreImage

@objc
private class DebugQuickLookObjectShim: NSObject {
    @objc(debugQuickLookObject)
    func debugQuickLookObject() -> AnyObject? { return nil }
}

/// The sum of types that can be used as a Quick Look representation.
public enum PlaygroundQuickLook {
    /// Plain text.
    case text(String)
    
    /// An integer numeric value.
    case int(Int64)
    
    /// An unsigned integer numeric value.
    case uInt(UInt64)
    
    /// A single precision floating-point numeric value.
    case float(Float32)
    
    /// A double precision floating-point numeric value.
    case double(Float64)
    
    // FIXME: Uses an Any to avoid coupling a particular Cocoa type.
    /// An image.
    case image(Any)
    
    // FIXME: Uses an Any to avoid coupling a particular Cocoa type.
    /// A sound.
    case sound(Any)
    
    // FIXME: Uses an Any to avoid coupling a particular Cocoa type.
    /// A color.
    case color(Any)
    
    // FIXME: Uses an Any to avoid coupling a particular Cocoa type.
    /// A bezier path.
    case bezierPath(Any)
    
    // FIXME: Uses an Any to avoid coupling a particular Cocoa type.
    /// An attributed string.
    case attributedString(Any)
    
    // FIXME: Uses explicit coordinates to avoid coupling a particular Cocoa type.
    /// A rectangle.
    case rectangle(Float64, Float64, Float64, Float64)
    
    // FIXME: Uses explicit coordinates to avoid coupling a particular Cocoa type.
    /// A point.
    case point(Float64, Float64)
    
    // FIXME: Uses explicit coordinates to avoid coupling a particular Cocoa type.
    /// A size.
    case size(Float64, Float64)
    
    /// A boolean value.
    case bool(Bool)
    
    // FIXME: Uses explicit values to avoid coupling a particular Cocoa type.
    /// A range.
    case range(Int64, Int64)
    
    // FIXME: Uses an Any to avoid coupling a particular Cocoa type.
    /// A GUI view.
    case view(Any)
    
    // FIXME: Uses an Any to avoid coupling a particular Cocoa type.
    /// A graphical sprite.
    case sprite(Any)
    
    /// A Uniform Resource Locator.
    case url(String)
    
    /// Raw data that has already been encoded in a format the IDE understands.
    case _raw([UInt8], String)
}

extension PlaygroundQuickLook {
    /// Creates a new Quick Look for the given instance.
    ///
    /// If the dynamic type of `subject` conforms to
    /// `CustomPlaygroundQuickLookable`, the result is found by calling its
    /// `customPlaygroundQuickLook` property. Otherwise, the result is
    /// synthesized by the language. In some cases, the synthesized result may
    /// be `.text(String(reflecting: subject))`.
    ///
    /// - Note: If the dynamic type of `subject` has value semantics, subsequent
    ///   mutations of `subject` will not observable in the Quick Look. In
    ///   general, though, the observability of such mutations is unspecified.
    ///
    /// - Parameter subject: The instance to represent with the resulting Quick
    ///   Look.
    public init(reflecting subject: Any) {
        // If the subject conforms to CustomPlaygroundQuickLookable, use that.
        if let customized = subject as? CustomPlaygroundQuickLookable {
            self = customized.customPlaygroundQuickLook
        }
            
        // If the subject conforms to _DefaultCustomPlaygroundQuickLookable, use that.
        else if let customized = subject as? _DefaultCustomPlaygroundQuickLookable {
            self = customized._defaultCustomPlaygroundQuickLook
        }
            
        // Otherwise, fall back to the default behavior (previously provided by the legacy _Mirror).
        else {
            // If the subject is an Objective-C object implementing -debugQuickLookObject, use that.
            if let debugQuickLookObjectMethod = (subject as AnyObject).debugQuickLookObject,
               let returnedObject = debugQuickLookObjectMethod(),
               let debugQuickLookObject = returnedObject as? DebugQuickLookObject {
                self = debugQuickLookObject.convertToPlaygroundQuickLook()
            }
            
            // If the subject itself is an object which can be returned from -debugQuickLookObject, use that.
            else if let debugQuickLookObject = subject as? DebugQuickLookObject {
                self = debugQuickLookObject.convertToPlaygroundQuickLook()
            }
            
            // Otherwise, fall back to a textual representation of the subject.
            else {
                self = .text(String(reflecting: subject))
            }
        }
    }
}

/// A type that explicitly supplies its own playground Quick Look.
///
/// A Quick Look can be created for an instance of any type by using the
/// `PlaygroundQuickLook(reflecting:)` initializer. If you are not satisfied
/// with the representation supplied for your type by default, you can make it
/// conform to the `CustomPlaygroundQuickLookable` protocol and provide a
/// custom `PlaygroundQuickLook` instance.
public protocol CustomPlaygroundQuickLookable {
    /// A custom playground Quick Look for this instance.
    ///
    /// If this type has value semantics, the `PlaygroundQuickLook` instance
    /// should be unaffected by subsequent mutations.
    var customPlaygroundQuickLook: PlaygroundQuickLook { get }
}

// A workaround for <rdar://problem/26182650>
public protocol _DefaultCustomPlaygroundQuickLookable {
    var _defaultCustomPlaygroundQuickLook: PlaygroundQuickLook { get }
}

// MARK: - DebugQuickLookObject protocol and conformances

/// A protocol which allows types to be valid values returned by
/// `-debugQuickLookObject`.
fileprivate protocol DebugQuickLookObject: class {
    func convertToPlaygroundQuickLook() -> PlaygroundQuickLook
}

extension NSNumber: DebugQuickLookObject {
    fileprivate func convertToPlaygroundQuickLook() -> PlaygroundQuickLook {
        switch UInt8(self.objCType[0]) {
        case UInt8(ascii: "d"):
            return .double(doubleValue)
        case UInt8(ascii: "f"):
            return .float(floatValue)
        case UInt8(ascii: "Q"):
            return .uInt(uint64Value)
        default:
            return .int(int64Value)
        }
    }
}

extension NSAttributedString: DebugQuickLookObject {
    fileprivate func convertToPlaygroundQuickLook() -> PlaygroundQuickLook {
        return .attributedString(self)
    }
}

#if os(macOS)
    extension NSImage: DebugQuickLookObject {
        fileprivate func convertToPlaygroundQuickLook() -> PlaygroundQuickLook {
            return .image(self)
        }
    }
    
    extension NSImageView: DebugQuickLookObject {
        fileprivate func convertToPlaygroundQuickLook() -> PlaygroundQuickLook {
            return .image(self)
        }
    }
    
    extension NSBitmapImageRep: DebugQuickLookObject {
        fileprivate func convertToPlaygroundQuickLook() -> PlaygroundQuickLook {
            return .image(self)
        }
    }
    
    extension NSColor: DebugQuickLookObject {
        fileprivate func convertToPlaygroundQuickLook() -> PlaygroundQuickLook {
            return .color(self)
        }
    }
    
    extension NSBezierPath: DebugQuickLookObject {
        fileprivate func convertToPlaygroundQuickLook() -> PlaygroundQuickLook {
            return .bezierPath(self)
        }
    }
#endif

#if os(iOS) || os(tvOS)
    extension UIImage: DebugQuickLookObject {
        fileprivate func convertToPlaygroundQuickLook() -> PlaygroundQuickLook {
            return .image(self)
        }
    }
    
    extension UIImageView: DebugQuickLookObject {
        fileprivate func convertToPlaygroundQuickLook() -> PlaygroundQuickLook {
            return .image(self)
        }
    }

    extension UIColor: DebugQuickLookObject {
        fileprivate func convertToPlaygroundQuickLook() -> PlaygroundQuickLook {
            return .color(self)
        }
    }
    
    extension UIBezierPath: DebugQuickLookObject {
        fileprivate func convertToPlaygroundQuickLook() -> PlaygroundQuickLook {
            return .bezierPath(self)
        }
    }
#endif

extension CIImage: DebugQuickLookObject {
    fileprivate func convertToPlaygroundQuickLook() -> PlaygroundQuickLook {
        return .image(self)
    }
}

extension NSString: DebugQuickLookObject {
    fileprivate func convertToPlaygroundQuickLook() -> PlaygroundQuickLook {
        return .text(self as String)
    }
}
