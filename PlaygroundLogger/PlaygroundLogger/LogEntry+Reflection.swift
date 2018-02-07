//===--- LogEntry+Reflection.swift ----------------------------------------===//
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

import Foundation
import CoreGraphics

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
        
        // For types which conform to the `CustomOpaqueLoggable` protocol, get their custom representation and construct an opaque log entry. (This is checked *second* so that user implementations of `CustomPlaygroundRepresentable` are honored over this framework's implementations of `CustomOpaqueLoggable`.)
        if let customOpaqueLoggable = instance as? CustomOpaqueLoggable {
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
            
        // If a type implements the `debugQuickLookObject()` Objective-C method, then get their debug quick look object and use that for logging (by passing it back through this initializer).
        else if let debugQuickLookObjectMethod = (instance as AnyObject).debugQuickLookObject, let debugQuickLookObject = debugQuickLookObjectMethod() {
            self = .init(describing: debugQuickLookObject, name: name, typeName: typeName, summary: nil)
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
                
                // Get a Mirror which reflects the instance being logged.
                let mirror = Mirror(reflecting: instance)
                
                if mirror.displayStyle == .optional && mirror.children.count == 1 {
                    // If the mirror displays as an Optional and has exactly one child, then we want to unwrap the optionality and generate a log entry for the child.
                    self = .init(describing: mirror.children.first!.value, name: name, typeName: typeName, summary: nil)
                }
                else {
                    // Otherwise, we want to generate a log entry with the structure from the mirror.
                    self = .init(structureFrom: mirror, name: name, typeName: typeName, summary: summary)
                }
            }
        }
    }
    
    private init(playgroundQuickLook: PlaygroundQuickLook, name: String, typeName: String, summary: String) {
        // TODO: figure out when to set `preferBriefSummary` to true
        self = .opaque(name: name, typeName: typeName, summary: summary, preferBriefSummary: false, representation: playgroundQuickLook.opaqueRepresentation)
    }
    
    private init(structureFrom mirror: Mirror, name: String, typeName: String, summary: String) {
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
