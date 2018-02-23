//===--- LogPolicy.swift --------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

struct LogPolicy {
    static let `default`: LogPolicy = LogPolicy()

    enum ChildPolicy {
        /// Indicates that all children should be logged.
        case all
        /// Indicates that no more than the first `count` children should be logged.
        case head(count: Int)
        /// Indicates that no more than the first `headCount` and last `tailCount` children should be logged.
        case headTail(headCount: Int, tailCount: Int)
        /// Indicates that no children should be logged.
        case none
    }

    /// The policy for logging children of aggregates (e.g. classes, structs, enums, tuples).
    var aggregateChildPolicy: ChildPolicy

    /// The policy for logging children of containers (e.g. optionals, collections, dictionaries, sets).
    var containerChildPolicy: ChildPolicy

    /// Initializes a new `LogPolicy`.
    ///
    /// - parameter aggregateChildPolicy: The policy to use for logging children of aggregates. Defaults to logging no more than the first 10,000 children.
    /// - parameter containerChildPolicy: The policy to use for logging children of collections. Defaults to logging no more than the first 80 children plus the last 20 children.
    init(aggregateChildPolicy: ChildPolicy = .head(count: 10_000),
         containerChildPolicy: ChildPolicy = .headTail(headCount: 80, tailCount: 20)) {
        self.aggregateChildPolicy = aggregateChildPolicy
        self.containerChildPolicy = containerChildPolicy
    }
}
