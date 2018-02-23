//===--- NSBitmapImageRep+OpaqueImageRepresentable.swift ------------------===//
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
    
    extension NSBitmapImageRep: OpaqueImageRepresentable {
        func encodeImage(into encoder: LogEncoder, withFormat format: LogEncoder.Format) {
            guard let pngData = self.representation(using: .png, properties: [:]) else {
                unimplemented("Need to handle error when we couldn't generate PNG data")
            }

            encoder.encode(number: UInt64(pngData.count))
            encoder.encode(data: pngData)
        }
    }
#endif
