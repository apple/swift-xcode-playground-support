//===--- PlaygroundQuickLook+OpaqueRepresentationSupport.swift ------------===//
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

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

extension PlaygroundQuickLook {
    var opaqueRepresentation: LogEntry.OpaqueRepresentation {
        // TODO: don't crash in this function; instead, throw an error so we can encode an error log message instead
        
        switch self {
        case let .text(text):
            return text
        case let .int(int):
            return int
        case let .uInt(uInt):
            return uInt
        case let .float(float):
            return float
        case let .double(double):
            return double
        case let .image(image):
            #if os(macOS)
                guard let image = image as? NSImage else {
                    fatalError("Must be an NSImage")
                }
                
                return ImageOpaqueRepresentation(kind: .image, backedBy: image)
            #elseif os(iOS) || os(tvOS)
                guard let image = image as? UIImage else {
                    fatalError("Must be an IOImage")
                }
                
                return ImageOpaqueRepresentation(kind: .image, backedBy: image)
                
            #endif
        case .sound:
            fatalError("Sounds not yet supported")
        case let .color(color):
            #if os(macOS)
                guard let color = color as? NSColor else {
                    fatalError("Must be an NSColor")
                }
                
                return color.cgColor
            #elseif os(iOS) || os(tvOS)
                guard let color = color as? UIColor else {
                    fatalError("Must be a UIColor")
                }
                
                return color.cgColor
            #endif
        case let .bezierPath(bezierPath):
            #if os(macOS)
                guard let bezierPath = bezierPath as? NSBezierPath else {
                    fatalError("Must be an NSBezierPath")
                }
                
                return bezierPath
            #elseif os(iOS) || os(tvOS)
                guard let bezierPath = bezierPath as? UIBezierPath else {
                    fatalError("Must be a UIBezierPath")
                }
                
                return bezierPath
            #endif
        case let .attributedString(attributedString):
            guard let attributedString = attributedString as? NSAttributedString else {
                fatalError("Must be an NSAttributedString")
            }
            
            return attributedString
        case let .rectangle(x, y, width, height):
            return CGRect(x: x, y: y, width: width, height: height)
        case let .point(x, y):
            return CGPoint(x: x, y: y)
        case let .size(width, height):
            return CGSize(width: width, height: height)
        case let .bool(bool):
            return bool
        case let .range(location, length):
            return NSRange(location: Int(location), length: Int(length))
        case let .view(viewOrImage):
            #if os(macOS)
                if let view = viewOrImage as? NSView {
                    return ImageOpaqueRepresentation(kind: .view, backedBy: view)
                }
                else if let image = viewOrImage as? NSImage {
                    return ImageOpaqueRepresentation(kind: .view, backedBy: image)
                }
                else {
                    fatalError("Must be an NSView or NSImage")
                }
            #elseif os(iOS) || os(tvOS)
                if let view = viewOrImage as? UIView {
                    return ImageOpaqueRepresentation(kind: .view, backedBy: view)
                }
                else if let image = viewOrImage as? UIImage {
                    return ImageOpaqueRepresentation(kind: .view, backedBy: image)
                }
                else {
                    fatalError("Must be a UIView or UIImage")
                }
            #endif
        case let .sprite(image):
            // TODO: figure out if this is even a little bit right. (The previous implementation just logged a string for sprites?)
            #if os(macOS)
                guard let image = image as? NSImage else {
                    fatalError("Must be an NSImage")
                }
                
                return ImageOpaqueRepresentation(kind: .sprite, backedBy: image)
            #elseif os(iOS) || os(tvOS)
                guard let image = image as? UIImage else {
                    fatalError("Must be a UIImage")
                }
                
                return ImageOpaqueRepresentation(kind: .sprite, backedBy: image)
            #endif
        case let .url(urlString):
            guard let url = URL(string: urlString) else {
                fatalError("Must be a valid URL string!")
            }
            
            return url
        case let ._raw(bytes, tag):
            struct RawOpaqueRepresentation: TaggedOpaqueRepresentation {
                var tag: String
                var bytes: [UInt8]
                
                func encodePayload(into encoder: LogEncoder, usingFormat format: LogEncoder.Format) {
                    encoder.encode(number: UInt64(bytes.count))
                    encoder.encode(bytes: bytes, length: bytes.count)
                }
            }
            
            return RawOpaqueRepresentation(tag: tag, bytes: bytes)
        }
    }
}
