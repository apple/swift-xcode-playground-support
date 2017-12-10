//===--- CGColor+KeyedArchiveOpaqueRepresentation.swift -------------------===//
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

import CoreGraphics
import Foundation

fileprivate let colorTag = "COLR"

fileprivate let colorSpaceKey = "IDEColorSpaceKey"
fileprivate let colorComponentsKey = "IDEColorComponentsKey"

extension CGColor: KeyedArchiveOpaqueRepresentation {
    var tag: String { return colorTag }
    
    func encodeOpaqueRepresentation(with encoder: NSCoder, usingFormat format: LogEncoder.Format) {
        guard let colorSpace = self.colorSpace else {
            unimplemented("Need to handle colors without a color space somehow")
        }
        
        guard colorSpace.model != .pattern else {
            unimplemented("Need to handle pattern colors")
        }
        
        guard let colorSpaceName = colorSpace.name, let components = self.components else {
            unimplemented("Need to handle colors with an unnamed color space or with missing components")
        }
        
        encoder.encode(colorSpaceName as NSString, forKey: colorSpaceKey)
        encoder.encode(components.map { $0 as NSNumber } as NSArray, forKey: colorComponentsKey)
    }
}
