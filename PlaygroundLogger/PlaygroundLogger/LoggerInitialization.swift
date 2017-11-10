//===--- LoggerInitialization.swift ---------------------------------------===//
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
import PlaygroundRuntime

/// Initializes the PlaygroundLogger framework.
///
/// - note: This function is invoked via lldb using @_silgen_name.
@_silgen_name("playground_logger_initialize")
public func initializePlaygroundLogger() -> Void {
    Swift._playgroundPrintHook = printHook
    PlaygroundRuntime.$builtin_log_with_id = logResult
    PlaygroundRuntime.$builtin_log_scope_entry = logScopeEntry
    PlaygroundRuntime.$builtin_log_scope_exit = logScopeExit
    PlaygroundRuntime.$builtin_postPrint = logPostPrint
}
