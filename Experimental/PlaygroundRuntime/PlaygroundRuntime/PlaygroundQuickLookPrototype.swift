//===--- PlaygroundQuickLookPrototype.swift -------------------------------===//
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

/// A protocol which allows a type to represent its instances with an alternate
/// object or value.
public protocol CustomPlaygroundRepresentable {
    /// The alternate object or value which represents the receiver.
    ///
    /// - note: The value returned from this property will then be asked if it
    ///         too conforms to `CustomPlaygroundRepresentable`. To avoid
    ///         infinite recursion, this may be capped to a reasonable limit.
    var playgroundRepresentation: Any { get }
}
