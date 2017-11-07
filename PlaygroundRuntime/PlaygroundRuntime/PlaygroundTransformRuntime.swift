//===--- PlaygroundTransformRuntime.swift ---------------------------------===//
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

fileprivate func unsetResultFunction(_: Any, _: String, _: Int, _: Int, _: Int, _: Int, _: Int) {
    fatalError("Playground transform runtime uninitialized")
}

fileprivate func unsetEventFunction(_: Int, _: Int, _: Int, _: Int) {
    fatalError("Playground transform runtime uninitialized")
}

public var $builtin_log_with_id: @convention(thin) (Any, String, Int, Int, Int, Int, Int) -> Void = unsetResultFunction
public var $builtin_log_scope_entry: @convention(thin) (Int, Int, Int, Int) -> Void = unsetEventFunction
public var $builtin_log_scope_exit: @convention(thin) (Int, Int, Int, Int) -> Void = unsetEventFunction
public var $builtin_postPrint: @convention(thin) (Int, Int, Int, Int) -> Void = unsetEventFunction

// TODO: remove this once it's no longer necessary
public func $builtin_send_data(_ :  Void) {}
