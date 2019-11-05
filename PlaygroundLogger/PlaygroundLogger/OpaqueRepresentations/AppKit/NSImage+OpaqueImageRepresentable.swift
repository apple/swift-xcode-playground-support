//===--- NSImage+OpaqueImageRepresentable.swift ---------------------------===//
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
    
    extension NSImage: OpaqueImageRepresentable {
        private var bestBitmapRepresentation: NSBitmapImageRep? {
            guard let bestRep = self.bestRepresentation(for: NSRect(origin: .zero, size: size).integral, context: nil, hints: nil) else {
                // We don't have a best representation, so we can't convert it to a bitmap image rep.
                return nil
            }

            if let bitmapRep = bestRep as? NSBitmapImageRep {
                return bitmapRep
            }
            else {
                guard let cgImage = bestRep.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                    return nil
                }

                return NSBitmapImageRep(cgImage: cgImage)
            }
        }

        func encodeImage(into encoder: LogEncoder, withFormat format: LogEncoder.Format) throws {
            guard let bitmapRep = self.bestBitmapRepresentation else {
                if (size == .zero) || self.representations.isEmpty  {
                    // If we couldn't get a bitmap representation because the image was empty, encode empty PNG data.
                    encoder.encode(number: 0)
                    return
                }
                else {
                    throw LoggingError.encodingFailure(reason: "Failed to get a bitmap representation of this NSImage")
                }
            }

            try bitmapRep.encodeImage(into: encoder, withFormat: format)
        }
    }
#endif
