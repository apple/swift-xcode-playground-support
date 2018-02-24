//===--- NSBezierPath+KeyedArchiveOpaqueRepresentation.swift --------------===//
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

#if os(macOS)
    import Foundation
    import AppKit
    
    fileprivate let bezierPathTag = "BEZP"
    
    extension NSBezierPath: KeyedArchiveOpaqueRepresentation {
        var tag: String { return bezierPathTag }
        
        func encodeOpaqueRepresentation(with encoder: NSCoder, usingFormat format: LogEncoder.Format) throws {
            do {
                try self.encodeForLogEntry(using: encoder)
            }
            catch {
                throw LoggingError.encodingFailure(reason: "Failed to encode NSBezierPath using NSKeyedArchiver")
            }
        }
    }
#endif
