//===--- Integers+CustomOpaqueLoggable.swift ------------------------------===//
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

extension Int: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return Int64(self)
    }
}

extension Int8: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return Int64(self)
    }
}

extension Int16: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return Int64(self)
    }
}

extension Int32: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return Int64(self)
    }
}

extension Int64: CustomOpaqueLoggable {}

extension UInt: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return UInt64(self)
    }
}

extension UInt8: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return UInt64(self)
    }
}

extension UInt16: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return UInt64(self)
    }
}

extension UInt32: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return UInt64(self)
    }
}

extension UInt64: CustomOpaqueLoggable {}
