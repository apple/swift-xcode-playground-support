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
            
        // For types which conform to the `CustomOpaqueLoggable` protocol, get their custom representation and construct an opaque log entry. (This is checked *second* so that user implementations of `CustomPlaygroundRepresentable` are honored over this framework's implementations of `CustomOpaqueLoggable`.)
        else if let customOpaqueLoggable = instance as? CustomOpaqueLoggable {
            // TODO: figure out when to set `preferBriefSummary` to true
            self = .opaque(name: name, typeName: typeName, summary: summary, preferBriefSummary: false, representation: customOpaqueLoggable.opaqueRepresentation)
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
            
        // Otherwise, first check if this is an interesting CF type before logging structure.
        // This works around SR-2289/<rdar://problem/27116100>.
        else {
            switch CFGetTypeID(instance as CFTypeRef) {
            case CGColor.typeID:
                let cgColor = instance as! CGColor
                self = .opaque(name: name, typeName: typeName, summary: summary, preferBriefSummary: false, representation: cgColor.opaqueRepresentation)
            case CGImage.typeID:
                let cgImage = instance as! CGImage
                self = .opaque(name: name, typeName: typeName, summary: summary, preferBriefSummary: false, representation: cgImage.opaqueRepresentation)
            default:
                // This isn't one of the CF types we want to specially handle, so the log entry should just reflect the instance's structure.
                self = .init(structureOf: instance, name: name, typeName: typeName, summary: summary)
            }
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
