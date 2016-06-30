//
//  ExtensionQuickLookObject.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

extension QuickLookObject {
    // checks the rules for the "prefer summary" flag to be set
    func shouldPreferSummary(mirror: LoggerMirror) -> Bool {
#if APPLE_FRAMEWORKS_AVAILABLE
        if let obj = mirror.value as? AnyObject {
            if obj.responds(to: Selector(("debugQuickLookObject"))) {
                switch self {
                case .text(_), .attributedString(_), .int(_), .uInt(_), .float(_): return false
                default: return true
                }
            }
        }
#endif
        return false
    }
}

extension QuickLookObject {
    func getStringIfAny() -> String? {
        switch self {
        case .text(let str): return str
        default: return nil
        }
    }
}

