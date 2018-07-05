//===--- String+CustomOpaqueLoggable.swift --------------------------------===//
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

extension String: CustomOpaqueLoggable {}

extension Character: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return String(self)
    }
}

extension UnicodeScalar: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return UInt64(self)
    }
}

extension String.UnicodeScalarView: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return self.description
    }
}

extension String.UTF16View: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return self.description
    }
}

extension String.UTF8View: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return self.description
    }
}
