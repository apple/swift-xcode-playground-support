//===--- LoggerInitialization.swift ---------------------------------------===//
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

/// Initializes the PlaygroundLogger framework.
///
/// - note: This function is invoked by host stubs via dlsym.
@_cdecl("PGLInitializePlaygroundLogger")
public func initializePlaygroundLogger(clientVersion: Int, sendData: @escaping SendDataFunction) -> Void {
    Swift._playgroundPrintHook = printHook
    PlaygroundLogger.sendData = sendData
    
    // TODO: take clientVersion and use to customize PlaygroundLogger behavior.
}
