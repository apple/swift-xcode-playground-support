//===--- UIView+OpaqueImageRepresentable.swift ----------------------------===//
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

#if os(iOS) || os(tvOS)
    import UIKit
    
    extension UIView: OpaqueImageRepresentable {
        func encodeImage(into encoder: LogEncoder, withFormat format: LogEncoder.Format) {
            guard Thread.isMainThread else {
                // If we're not on the main thread, then just encode empty PNG data.
                encoder.encode(number: 0)
                return
            }

            let ir = UIGraphicsImageRenderer(size: bounds.size)
            let pngData = ir.pngData { _ in
                self.drawHierarchy(in: bounds, afterScreenUpdates: true)
            }

            encoder.encode(number: UInt64(pngData.count))
            encoder.encode(data: pngData)
        }
    }
#endif

