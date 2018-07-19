//===--- UnsafePointers+CustomOpaqueLoggable.swift ------------------------===//
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

extension UnsafePointer: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        let uintValue = UInt64(UInt(bitPattern: self))
        return "UnsafePointer(\(uintValue == 0 ? "nil" : String(uintValue, radix: 16, uppercase: true)))"
    }
}

extension UnsafeRawPointer: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        let uintValue = UInt64(UInt(bitPattern: self))
        return "UnsafeRawPointer(\(uintValue == 0 ? "nil" : String(uintValue, radix: 16, uppercase: true)))"
    }
}

extension UnsafeMutablePointer: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        let uintValue = UInt64(UInt(bitPattern: self))
        return "UnsafeMutablePointer(\(uintValue == 0 ? "nil" : String(uintValue, radix: 16, uppercase: true)))"
    }
}

extension UnsafeMutableRawPointer: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        let uintValue = UInt64(UInt(bitPattern: self))
        return "UnsafeMutableRawPointer(\(uintValue == 0 ? "nil" : String(uintValue, radix: 16, uppercase: true)))"
    }
}
