//===--- Date+CustomOpaqueLoggable.swift ----------------------------------===//
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

fileprivate let dateLoggingFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

extension Date: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return dateLoggingFormatter.string(from: self)
    }
}

extension NSDate: CustomOpaqueLoggable {
    func opaqueRepresentation() -> LogEntry.OpaqueRepresentation {
        return (self as Date).opaqueRepresentation()
    }
}
