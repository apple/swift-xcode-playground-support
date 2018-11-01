//===--- UIImage+OpaqueImageRepresentable.swift ---------------------------===//
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

#if os(iOS) || os(tvOS)
    import UIKit
    
    extension UIImage: OpaqueImageRepresentable {
        func encodeImage(into encoder: LogEncoder, withFormat format: LogEncoder.Format) throws {
            guard let pngData = self.pngData() else {
                if size == .zero {
                    // We tried encoding an empty image, so it understandably failed.
                    // In this case, simply encode empty PNG data.
                    encoder.encode(number: 0)
                    return
                }
                else {
                    throw LoggingError.encodingFailure(reason: "Failed to convert UIImage to PNG")
                }
            }

            encoder.encode(number: UInt64(pngData.count))
            encoder.encode(data: pngData)
        }
    }
#endif
