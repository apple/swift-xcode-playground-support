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

#if os(iOS) || os(tvOS)
    import UIKit
    
    typealias Image = UIImage
    typealias Color = UIColor
    typealias BezierPath = UIBezierPath
#elseif os(macOS)
    import AppKit
    
    typealias Image = NSImage
    typealias Color = NSColor
    typealias BezierPath = NSBezierPath
#endif

enum LogEntry {
    enum OpaqueRepresentation {
        case string(String)
        case signedInteger(Int64)
        case unsignedInteger(UInt64)
        case float(Float)
        case double(Double)
        case boolean(Bool)
        case image(Image)
        // TODO: determine if this should be NS/UIView instead
        case view(Image)
        // TODO: determine if this should be SKSpriteNode instead
        case sprite(Image)
        case color(Color)
        case bezierPath(BezierPath)
        case attributedString(NSAttributedString)
        case point(CGPoint)
        case size(CGSize)
        case rect(CGRect)
        case range(NSRange)
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
    case opaque(name: String, typeName: String, summary: String, preferBriefSummary: Bool, representation: OpaqueRepresentation)
    case gap
    case scopeEntry, scopeExit
    case error(reason: String)
}
