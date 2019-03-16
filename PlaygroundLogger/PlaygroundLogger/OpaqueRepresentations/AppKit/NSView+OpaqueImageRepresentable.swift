//===--- NSView+OpaqueImageRepresentable.swift ----------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2017-2019 Apple Inc. and the Swift project authors
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
            guard Thread.isMainThread else {
                // If we're not on the main thread, then just encode empty PNG data.
                encoder.encode(number: 0)
                return
            }

            guard let bitmapRep = self.bitmapImageRepForCachingDisplay(in: self.bounds) else {
                if self.bounds == .zero {
                    // If we couldn't get a bitmap representation because the view is zero-sized, encode empty PNG data.
                    encoder.encode(number: 0)
                    return
                }
                else {
                    throw LoggingError.encodingFailure(reason: "Unable to create a bitmap representation of this NSView")
                }
            }

            self.cacheDisplay(in: self.bounds, to: bitmapRep)

            try bitmapRep.encodeImage(into: encoder, withFormat: format)
        }
    }
#endif
