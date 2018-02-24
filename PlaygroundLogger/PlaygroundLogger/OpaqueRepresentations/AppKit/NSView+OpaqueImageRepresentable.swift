//===--- NSView+OpaqueImageRepresentable.swift ----------------------------===//
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
    import AppKit
    
    extension NSView: OpaqueImageRepresentable {
        func encodeImage(into encoder: LogEncoder, withFormat format: LogEncoder.Format) throws {
            guard let bitmapRep = self.bitmapImageRepForCachingDisplay(in: self.bounds) else {
                throw LoggingError.encodingFailure(reason: "Unable to create a bitmap representation of this NSView")
            }

            self.cacheDisplay(in: self.bounds, to: bitmapRep)

            try bitmapRep.encodeImage(into: encoder, withFormat: format)
        }
    }
#endif
