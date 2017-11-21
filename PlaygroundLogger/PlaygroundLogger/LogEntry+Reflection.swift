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
    fileprivate typealias Color = UIColor
#elseif os(macOS)
    import AppKit
    fileprivate typealias Color = NSColor
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
        self = .opaque(name: name, typeName: typeName, summary: summary, preferBriefSummary: false, representation: LogEntry.OpaqueRepresentation(playgroundQuickLook: playgroundQuickLook))
    }
    
    private init(debugQuickLookObject: AnyObject, name: String, typeName: String, summary: String) {
        fatalError()
    }
    
    private init(structureOf instance: Any, name: String, typeName: String, summary: String) {
        let mirror = Mirror(reflecting: instance)
        
        self = .structured(name: name, typeName: typeName, summary: summary, totalChildrenCount: Int(mirror.children.count), children: mirror.children.map { LogEntry(describing: $0.value, name: $0.label) }, disposition: .init(displayStyle: mirror.displayStyle))
    }
}

extension LogEntry.OpaqueRepresentation {
    fileprivate init(playgroundQuickLook: PlaygroundQuickLook) {
        // TODO: convert fatalErrors to throws
        
        switch playgroundQuickLook {
        case let .text(text):
            self = .string(text)
        case let .int(int):
            self = .signedInteger(int)
        case let .uInt(uInt):
            self = .unsignedInteger(uInt)
        case let .float(float):
            self = .float(float)
        case let .double(double):
            self = .double(double)
        case let .image(image):
            guard let image = image as? Image else {
                fatalError("Must be a \(Image.self)")
            }
            
            self = .image(image)
        case let .view(viewOrImage):
            if let view = viewOrImage as? View {
                self = .view(view)
            }
            else if let image = viewOrImage as? Image {
                self = .image(image)
            }
            else {
                fatalError("Must be a \(View.self) or \(Image.self)")
            }
        case let .sprite(image):
            // TODO: figure out if this is even a little bit right. (The previous implementation just logged a string for sprites?)
            guard let image = image as? Image else {
                fatalError("Must be a \(Image.self)")
            }
            
            self = .image(image)
        case .sound:
            fatalError("Sounds not supported")
        case let .color(color):
            guard let color = color as? Color else {
                fatalError("Must be a \(Color.self)")
            }
            
            self = .color(color.cgColor)
        case let .bezierPath(bezierPath):
            guard let bezierPath = bezierPath as? BezierPath else {
                fatalError("Must be a \(BezierPath.self)")
            }
            
            self = .bezierPath(bezierPath)
        case let .attributedString(attributedString):
            guard let attributedString = attributedString as? NSAttributedString else {
                fatalError("Must be an NSAttributedString")
            }
            
            self = .attributedString(attributedString)
        case let .rectangle(x, y, width, height):
            self = .rect(CGRect(x: x, y: y, width: width, height: height))
        case let .point(x, y):
            self = .point(CGPoint(x: x, y: y))
        case let .size(width, height):
            self = .size(CGSize(width: width, height: height))
        case let .bool(bool):
            self = .boolean(bool)
        case let .range(location, length):
            self = .nsRange(NSRange(location: Int(location), length: Int(length)))
        case let .url(urlString):
            guard let url = URL(string: urlString) else {
                fatalError("Must be a valid URL string!")
            }
            
            self = .url(url)
        case ._raw(_, _):
            fatalError("Raw case is unsupported in the new logger")
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
