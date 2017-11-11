//===--- SendData.swift ---------------------------------------------------===//
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

fileprivate func unsetSendData(_: NSData) {
    fatalError("PlaygroundLogger not initialized")
}

typealias SendDataFunction = @convention(c) (NSData) -> Void

var sendData: SendDataFunction = unsetSendData
