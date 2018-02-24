//===--- NSNumber+CustomOpaqueLoggable.swift ------------------------------===//
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

import Foundation

extension NSNumber: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        switch UInt8(self.objCType.pointee) {
        case UInt8(ascii: "c"), UInt8(ascii: "s"), UInt8(ascii: "i"), UInt8(ascii: "l"), UInt8(ascii: "q"):
            return self.int64Value
        case UInt8(ascii: "C"), UInt8(ascii: "S"), UInt8(ascii: "I"), UInt8(ascii: "L"), UInt8(ascii: "Q"):
            return self.uint64Value
        case UInt8(ascii: "f"):
            return self.floatValue
        case UInt8(ascii: "d"):
            return self.doubleValue
        case UInt8(ascii: "B"):
            return self.boolValue
        default:
            return self.int64Value
        }
    }
}
