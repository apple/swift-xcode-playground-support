//
//  PlaygroundLogScope.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

import Foundation

@_silgen_name("playground_log_scope_entry") public
func playground_log_scope_entry(_ startline: Int,
                                _ endline: Int,
                                _ startcolumn: Int,
                                _ endcolumn: Int) -> NSData {
    let range = (begin: (line: UInt64(startline), col: UInt64(startcolumn)), end: (line: UInt64(endline), col: UInt64(endcolumn)))
    let encoder = PlaygroundScopeWriter()
    encoder.encode(scope: .ScopeEntry, range: range)
    return encoder.stream.data
}

@_silgen_name("playground_log_scope_exit") public
func playground_log_scope_exit(_ startline: Int,
                               _ endline: Int,
                               _ startcolumn: Int,
                               _ endcolumn: Int) -> NSData {
    let range = (begin: (line: UInt64(startline), col: UInt64(startcolumn)), end: (line: UInt64(endline), col: UInt64(endcolumn)))
    let encoder = PlaygroundScopeWriter()
    encoder.encode(scope: .ScopeExit, range: range)
    return encoder.stream.data
}

