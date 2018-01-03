//===--- LoggerEntrypoints.swift ------------------------------------------===//
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

func logResult(_ result: Any,
               named name: String,
               withIdentifier identifier: Int,
               startLine: Int,
               endLine: Int,
               startColumn: Int,
               endColumn: Int) {
    let packet = LogPacket(describingResult: result, named: name, startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn)
    
    let data = packet.encode()
    
    sendData(data as NSData)
}

func logScopeEntry(startLine: Int,
                   endLine: Int,
                   startColumn: Int,
                   endColumn: Int) {
    let packet = LogPacket(scopeEntryWithStartLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn)
    
    let data = packet.encode()
    
    sendData(data as NSData)
}

func logScopeExit(startLine: Int,
                  endLine: Int,
                  startColumn: Int,
                  endColumn: Int) {
    let packet = LogPacket(scopeExitWithStartLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn)
    
    let data = packet.encode()
    
    sendData(data as NSData)
}

let printedStringThreadDictionaryKey: NSString = "org.swift.PlaygroundLogger.printedString"

func printHook(string: String) {
    Thread.current.threadDictionary[printedStringThreadDictionaryKey] = string as NSString
}

func logPostPrint(startLine: Int,
                  endLine: Int,
                  startColumn: Int,
                  endColumn: Int) {
    guard let printedString = Thread.current.threadDictionary[printedStringThreadDictionaryKey] as! String? else {
        return
    }
    
    Thread.current.threadDictionary.removeObject(forKey: printedStringThreadDictionaryKey)
    
    let packet = LogPacket(printedString: printedString, startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn)
    
    let data = packet.encode()
    
    sendData(data as NSData)
}
