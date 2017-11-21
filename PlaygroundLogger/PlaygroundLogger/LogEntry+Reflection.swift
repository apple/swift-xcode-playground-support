//===--- LogEntry+Reflection.swift ----------------------------------------===//
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
import PlaygroundRuntime // temporary, for CustomPlaygroundRepresentable

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

fileprivate class DebugQuickLookObjectHook: NSObject {
    @objc(debugQuickLookObject) func debugQuickLookObject() -> AnyObject? { return nil }
}

fileprivate let emptyNameString = ""

extension LogEntry {
    init(describing instance: Any, name: String? = nil) {
        self = .init(describing: instance, name: name ?? emptyNameString, typeName: nil, summary: nil)
    }
    
    private init(describing instance: Any, name: String, typeName passedInTypeName: String?, summary passedInSummary: String?) {
        // TODO: need to handle optionals better (e.g. implicitly unwrap optionality, I think)
        
        // Returns either the passed-in type name/summary or the type name/summary of `instance`.
        var typeName: String { return passedInTypeName ?? _typeName(type(of: instance)) }
        var summary: String { return passedInSummary ?? String(describing: instance) }
        
        // For types which conform to the `CustomPlaygroundRepresentable` protocol, get their custom representation and then run it back through the initializer.
        if let customRepresentable = instance as? CustomPlaygroundRepresentable {
            // Pass in our current type name so
            // TODO: pass nil or concrete summary?
            self = .init(describing: customRepresentable.playgroundRepresentation, name: name, typeName: typeName, summary: nil)
        }
        
        // For types which conform to the legacy `CustomPlaygroundQuickLookable` or `_DefaultCustomPlaygroundQuickLookable` protocols, get their `PlaygroundQuickLook` and use that for logging.
        else if let customQuickLookable = instance as? CustomPlaygroundQuickLookable {
            self = .init(playgroundQuickLook: customQuickLookable.customPlaygroundQuickLook, name: name, typeName: typeName, summary: summary)
        }
        else if let defaultQuickLookable = instance as? _DefaultCustomPlaygroundQuickLookable {
            self = .init(playgroundQuickLook: defaultQuickLookable._defaultCustomPlaygroundQuickLook, name: name, typeName: typeName, summary: summary)
        }
            
        // If a type implements the `debugQuickLookObject()` Objective-C method, then get their debug quick look object and use that for logging.
        else if let debugQuickLookObjectMethod = (instance as AnyObject).debugQuickLookObject, let debugQuickLookObject = debugQuickLookObjectMethod() {
            self = .init(debugQuickLookObject: debugQuickLookObject, name: name, typeName: typeName, summary: summary)
        }
            
        // Otherwise, simply log the structure of `instance`.
        else {
            self = .init(structureOf: instance, name: name, typeName: typeName, summary: summary)
        }
    }
    
    private init(playgroundQuickLook: PlaygroundQuickLook, name: String, typeName: String, summary: String) {
        // TODO: figure out when to set `preferBriefSummary` to true
        self = .opaque(name: name, typeName: typeName, summary: summary, preferBriefSummary: false, representation: playgroundQuickLook.opaqueRepresentation)
    }
    
    private init(debugQuickLookObject: AnyObject, name: String, typeName: String, summary: String) {
        fatalError()
    }
    
    private init(structureOf instance: Any, name: String, typeName: String, summary: String) {
        let mirror = Mirror(reflecting: instance)
        
        self = .structured(name: name, typeName: typeName, summary: summary, totalChildrenCount: Int(mirror.children.count), children: mirror.children.map { LogEntry(describing: $0.value, name: $0.label) }, disposition: .init(displayStyle: mirror.displayStyle))
    }
}

extension PlaygroundQuickLook {
    var opaqueRepresentation: LogEntry.OpaqueRepresentation {
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

extension LogEntry.StructuredDisposition {
    fileprivate init(displayStyle: Mirror.DisplayStyle?) {
        guard let displayStyle = displayStyle else {
            self = .container
            return
        }
        
        switch displayStyle {
        case .`struct`:
            self = .`struct`
        case .`class`:
            self = .`class`
        case .`enum`:
            self = .`enum`
        case .tuple:
            self = .tuple
        case .optional:
            self = .aggregate
        case .collection:
            self = .indexContainer
        case .dictionary:
            self = .keyContainer
        case .set:
            self = .membershipContainer
        }
    }
}
