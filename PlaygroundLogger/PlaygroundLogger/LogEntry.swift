//===--- LogEntry.swift ---------------------------------------------------===//
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
import CoreGraphics

protocol OpaqueLogEntryRepresentation {
    func encode(into encoder: LogEncoder, usingFormat format: LogEncoder.Format)
}

#if os(iOS) || os(tvOS)
    import UIKit
    
    typealias Image = UIImage
    typealias BezierPath = UIBezierPath
    typealias View = UIView
#elseif os(macOS)
    import AppKit
    
    typealias Image = NSImage
    typealias BezierPath = NSBezierPath
    typealias View = NSView
#endif

enum LogEntry {
    @available(*, deprecated)
    enum OpaqueRepresentation {
        case string(String)
        case signedInteger(Int64)
        case unsignedInteger(UInt64)
        case float(Float)
        case double(Double)
        case boolean(Bool)
        case image(Image)
        case view(View)
        case sprite(Image)
        case color(CGColor)
        case bezierPath(BezierPath)
        case attributedString(NSAttributedString)
        case point(CGPoint)
        case size(CGSize)
        case rect(CGRect)
        case nsRange(NSRange)
        case url(URL)
    }
    
    enum StructuredDisposition {
        case `class`
        case `struct`
        case tuple
        case `enum`
        case aggregate
        case container
        case indexContainer
        case keyContainer
        case membershipContainer
    }
    
    case structured(name: String, typeName: String, summary: String, totalChildrenCount: Int, children: [LogEntry], disposition: StructuredDisposition)
    case opaque(name: String, typeName: String, summary: String, preferBriefSummary: Bool, representation: OpaqueLogEntryRepresentation)
    case gap
    case scopeEntry, scopeExit
    case error(reason: String)
}

private let emptyName = ""

extension LogEntry {
    var name: String {
        switch self {
        case let .structured(name, _, _, _, _, _):
            return name
        case let .opaque(name, _, _, _, _):
            return name
        case .gap, .scopeEntry, .scopeExit, .error:
            return emptyName
        }
    }
}
