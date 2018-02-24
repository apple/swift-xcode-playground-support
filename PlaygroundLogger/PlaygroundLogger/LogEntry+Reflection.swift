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
    init(describing instance: Any, name: String? = nil, policy: LogPolicy) throws {
        self = try .init(describing: instance, name: name ?? emptyNameString, typeName: nil, summary: nil, policy: policy, currentDepth: 0)
    }
    
    fileprivate init(describing instance: Any, name: String, typeName passedInTypeName: String?, summary passedInSummary: String?, policy: LogPolicy, currentDepth: Int) throws {
        guard currentDepth <= policy.maximumDepth else {
            // We're trying to log an instance that is "too deep"; as a result, we need to just return a gap.
            self = .gap
            return
        }

        // Returns either the passed-in type name/summary or the type name/summary of `instance`.
        var typeName: String { return passedInTypeName ?? normalizedName(of: type(of: instance)) }
        var summary: String { return passedInSummary ?? String(describing: instance) }
        
        // For types which conform to the `CustomOpaqueLoggable` protocol, get their custom representation and construct an opaque log entry. (This is checked *second* so that user implementations of `CustomPlaygroundRepresentable` are honored over this framework's implementations of `CustomOpaqueLoggable`.)
        if let customOpaqueLoggable = instance as? CustomOpaqueLoggable {
            // TODO: figure out when to set `preferBriefSummary` to true
            self = try .opaque(name: name, typeName: typeName, summary: summary, preferBriefSummary: false, representation: customOpaqueLoggable.opaqueRepresentation())
        }
        
        // For types which conform to the legacy `CustomPlaygroundQuickLookable` or `_DefaultCustomPlaygroundQuickLookable` protocols, get their `PlaygroundQuickLook` and use that for logging.
        else if let customQuickLookable = instance as? CustomPlaygroundQuickLookable {
            self = try .init(playgroundQuickLook: customQuickLookable.customPlaygroundQuickLook, name: name, typeName: typeName, summary: summary)
        }
        else if let defaultQuickLookable = instance as? _DefaultCustomPlaygroundQuickLookable {
            self = try .init(playgroundQuickLook: defaultQuickLookable._defaultCustomPlaygroundQuickLook, name: name, typeName: typeName, summary: summary)
        }
            
        // If a type implements the `debugQuickLookObject()` Objective-C method, then get their debug quick look object and use that for logging (by passing it back through this initializer).
        else if let debugQuickLookObjectMethod = (instance as AnyObject).debugQuickLookObject, let debugQuickLookObject = debugQuickLookObjectMethod() {
            self = try .init(describing: debugQuickLookObject, name: name, typeName: typeName, summary: nil, policy: policy, currentDepth: currentDepth)
        }
            
        // Otherwise, first check if this is an interesting CF type before logging structure.
        // This works around SR-2289/<rdar://problem/27116100>.
        else {
            switch CFGetTypeID(instance as CFTypeRef) {
            case CGColor.typeID:
                let cgColor = instance as! CGColor
                self = .opaque(name: name, typeName: typeName, summary: summary, preferBriefSummary: false, representation: cgColor.opaqueRepresentation())
            case CGImage.typeID:
                let cgImage = instance as! CGImage
                self = .opaque(name: name, typeName: typeName, summary: summary, preferBriefSummary: false, representation: cgImage.opaqueRepresentation())
            default:
                // This isn't one of the CF types we want to specially handle, so the log entry should just reflect the instance's structure.
                
                // Get a Mirror which reflects the instance being logged.
                let mirror = Mirror(reflecting: instance)
                
                if mirror.displayStyle == .optional && mirror.children.count == 1 {
                    // If the mirror displays as an Optional and has exactly one child, then we want to unwrap the optionality and generate a log entry for the child.
                    self = try .init(describing: mirror.children.first!.value, name: name, typeName: typeName, summary: nil, policy: policy, currentDepth: currentDepth)
                }
                else {
                    // Otherwise, we want to generate a log entry with the structure from the mirror.
                    self = .init(structureFrom: mirror, name: name, typeName: typeName, summary: summary, policy: policy, currentDepth: currentDepth)
                }
            }
        }
    }
    
    private init(playgroundQuickLook: PlaygroundQuickLook, name: String, typeName: String, summary: String) throws {
        // TODO: figure out when to set `preferBriefSummary` to true
        self = try .opaque(name: name, typeName: typeName, summary: summary, preferBriefSummary: false, representation: playgroundQuickLook.opaqueRepresentation())
    }
    
    fileprivate static let superclassLogEntryName = "super"
    
    fileprivate init(structureFrom mirror: Mirror, name: String, typeName: String, summary: String, policy: LogPolicy, currentDepth: Int) {
        self = .structured(name: name,
                           typeName: typeName,
                           summary: summary,
                           totalChildrenCount: mirror.totalChildCount,
                           children: mirror.childEntries(using: policy, currentDepth: currentDepth),
                           disposition: .init(displayStyle: mirror.displayStyle)
        )
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

extension Mirror {
    fileprivate var totalChildCount: Int {
        if superclassMirror != nil {
            return Int(children.count) + 1
        }
        else {
            return Int(children.count)
        }
    }

    fileprivate func childEntries(using policy: LogPolicy, currentDepth: Int) -> [LogEntry] {
        let childPolicy: LogPolicy.ChildPolicy = {
            switch self.displayStyle ?? .struct {
            case .class, .struct, .tuple, .enum:
                return policy.aggregateChildPolicy
            case .optional, .collection, .dictionary, .set:
                return policy.containerChildPolicy
            }
        }()

        let childDepth: Int = {
            switch self.displayStyle ?? .struct {
            case .optional, .dictionary:
                // We don't consume a level of depth for optionals or dictionaries.
                // We don't want optional to count as a level of depth as we would quickly end up with gaps.
                // We don't want dictionary to count as a level of depth as dictionary is modeled as a collection of (key, value) pairs, and we don't want to lose a level due to the pairs themselves consuming a level, so for ease of bookkeeping the dictionary level is counted as not consuming a level.
                return currentDepth
            case .class, .struct, .tuple, .enum, .collection, .set:
                return currentDepth + 1
            }
        }()

        func logEntry(forChild child: Mirror.Child) -> LogEntry {
            do {
                return try LogEntry(describing: child.value, name: child.label ?? emptyNameString, typeName: nil, summary: nil, policy: policy, currentDepth: childDepth)
            }
            catch let LoggingError.failedToGenerateOpaqueRepresentation(reason) {
                return LogEntry.error(reason: reason)
            }
            catch LoggingError.encodingFailure {
                fatalError("Encoding failures should not be encountered while generating LogEntry values")
            }
            catch let LoggingError.otherFailure(reason) {
                return LogEntry.error(reason: reason)
            }
            catch {
                return LogEntry.error(reason: "Unknown error encountered when generating log entry")
            }
        }

        func logEntriesForAllChildren() -> [LogEntry] {
            let childEntries = children.map(logEntry(forChild:))
            if let superclassMirror = superclassMirror {
                return [superclassMirror.logEntry(named: LogEntry.superclassLogEntryName, usingPolicy: policy, depth: childDepth)] + childEntries
            }
            else {
                return childEntries
            }
        }

        func logEntries(forFirstChildren count: Int) -> [LogEntry] {
            let numberOfChildren: Int
            let superclassEntries: [LogEntry]
            if let superclassMirror = superclassMirror {
                superclassEntries = [superclassMirror.logEntry(named: LogEntry.superclassLogEntryName, usingPolicy: policy, depth: childDepth)]
                numberOfChildren = count - 1
            }
            else {
                superclassEntries = []
                numberOfChildren = count
            }

            let start = children.startIndex
            let max = children.index(start, offsetBy: numberOfChildren)

            return superclassEntries + children[start..<max].map(logEntry(forChild:))
        }

        func logEntries(forLastChildren count: Int) -> [LogEntry] {
            let max = children.endIndex
            let start = children.index(max, offsetBy: -count)

            return children[start..<max].map(logEntry(forChild:))
        }

        // Ensure that our children are loggable (i.e. their depth is not prohibited by our current policy).
        // If our children **are** too deep, then simply return a single gap as our children.
        guard childDepth <= policy.maximumDepth else {
            return [.gap]
        }

        switch childPolicy {
        case .all:
            return logEntriesForAllChildren()
        case let .head(count):
            if totalChildCount <= count {
                return logEntriesForAllChildren()
            }

            return logEntries(forFirstChildren: count) + [LogEntry.gap]
        case let .headTail(headCount, tailCount):
            if totalChildCount <= headCount + tailCount {
                return logEntriesForAllChildren()
            }

            return logEntries(forFirstChildren: headCount) + [LogEntry.gap] + logEntries(forLastChildren: tailCount)
        case .none:
            return []
        }
    }

    fileprivate func logEntry(named name: String, usingPolicy policy: LogPolicy, depth: Int) -> LogEntry {
        let subjectTypeName = normalizedName(of: self.subjectType)
        return LogEntry(structureFrom: self, name: name, typeName: subjectTypeName, summary: subjectTypeName, policy: policy, currentDepth: depth)
    }
}
