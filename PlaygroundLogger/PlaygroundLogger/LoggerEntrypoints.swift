//===--- LoggerEntrypoints.swift ------------------------------------------===//
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

import Foundation

func logResult(_ result: Any,
               named name: String,
               withIdentifier identifier: Int,
               startLine: Int,
               endLine: Int,
               startColumn: Int,
               endColumn: Int) {
    fatalError("Unimplemented function \(#function)")
}

func logScopeEntry(startLine: Int,
                   endLine: Int,
                   startColumn: Int,
                   endColumn: Int) {
    fatalError("Unimplemented function \(#function)")
}

func logScopeExit(startLine: Int,
                  endLine: Int,
                  startColumn: Int,
                  endColumn: Int) {
    fatalError("Unimplemented function \(#function)")
}

func printHook(string: String) {
    fatalError("Unimplemented function \(#function)")
}

func logPostPrint(startLine: Int,
                  endLine: Int,
                  startColumn: Int,
                  endColumn: Int) {
    fatalError("Unimplemented function \(#function)")
}
