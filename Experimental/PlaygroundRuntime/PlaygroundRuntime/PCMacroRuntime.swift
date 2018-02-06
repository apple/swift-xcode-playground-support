//===--- PCMacroRuntime.swift ---------------------------------------------===//
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

fileprivate func unsetPCFunction(_: Int, _: Int, _: Int, _: Int) {
    fatalError("PC macro runtime uninitialized")
}

public var __builtin_pc_before: @convention(thin) (Int, Int, Int, Int) -> Void = unsetPCFunction
public var __builtin_pc_after: @convention(thin) (Int, Int, Int, Int) -> Void = unsetPCFunction
