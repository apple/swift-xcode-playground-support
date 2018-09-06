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
    guard !PGLGetThreadIsLogging() else { return }
    PGLSetThreadIsLogging(true)
    defer { PGLSetThreadIsLogging(false) }
    
    let packet = LogPacket(describingResult: result, named: name, withPolicy: .default, startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn)
    
    let data: Data
    do {
        data = try packet.encode()
    }
    catch LoggingError.failedToGenerateOpaqueRepresentation {
        fatalError("Failures to generate opaque representations should not occur during encoding")
    }
    catch let LoggingError.encodingFailure(reason) {
        let errorPacket = LogPacket(errorWithReason: reason, startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn, threadID: packet.threadID)

        // Encoding an error packet should not fail under any circumstances.
        data = try! errorPacket.encode()
    }
    catch let LoggingError.otherFailure(reason) {
        let errorPacket = LogPacket(errorWithReason: reason, startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn, threadID: packet.threadID)

        // Encoding an error packet should not fail under any circumstances.
        data = try! errorPacket.encode()
    }
    catch {
        let errorPacket = LogPacket(errorWithReason: "Unknown failure encoding log packet", startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn, threadID: packet.threadID)

        // Encoding an error packet should not fail under any circumstances.
        data = try! errorPacket.encode()
    }
    
    sendData(data as NSData)
}

func logScopeEntry(startLine: Int,
                   endLine: Int,
                   startColumn: Int,
                   endColumn: Int) {
    guard !PGLGetThreadIsLogging() else { return }
    PGLSetThreadIsLogging(true)
    defer { PGLSetThreadIsLogging(false) }
    
    let packet = LogPacket(scopeEntryWithStartLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn)

    // Encoding a scope entry packet should not fail under any circumstances.
    let data = try! packet.encode()
    
    sendData(data as NSData)
}

func logScopeExit(startLine: Int,
                  endLine: Int,
                  startColumn: Int,
                  endColumn: Int) {
    guard !PGLGetThreadIsLogging() else { return }
    PGLSetThreadIsLogging(true)
    defer { PGLSetThreadIsLogging(false) }
    
    let packet = LogPacket(scopeExitWithStartLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn)

    // Encoding a scope exit packet should not fail under any circumstances.
    let data = try! packet.encode()
    
    sendData(data as NSData)
}

let printedStringThreadDictionaryKey: NSString = "org.swift.PlaygroundLogger.printedString"

func printHook(string: String) {
    // Don't store the printed string if we're already logging elsewhere in this thread.
    guard !PGLGetThreadIsLogging() else { return }
    
    Thread.current.threadDictionary[printedStringThreadDictionaryKey] = string as NSString
}

func logPostPrint(startLine: Int,
                  endLine: Int,
                  startColumn: Int,
                  endColumn: Int) {
    guard !PGLGetThreadIsLogging() else { return }
    PGLSetThreadIsLogging(true)
    defer { PGLSetThreadIsLogging(false) }
    
    guard let printedString = Thread.current.threadDictionary[printedStringThreadDictionaryKey] as! String? else {
        return
    }
    
    Thread.current.threadDictionary.removeObject(forKey: printedStringThreadDictionaryKey)
    
    let packet = LogPacket(printedString: printedString, startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn)
    
    let data: Data
    do {
        data = try packet.encode()
    }
    catch LoggingError.failedToGenerateOpaqueRepresentation {
        fatalError("Failures to generate opaque representations should not occur during encoding")
    }
    catch let LoggingError.encodingFailure(reason) {
        let errorPacket = LogPacket(errorWithReason: reason, startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn, threadID: packet.threadID)

        // Encoding an error packet should not fail under any circumstances.
        data = try! errorPacket.encode()
    }
    catch let LoggingError.otherFailure(reason) {
        let errorPacket = LogPacket(errorWithReason: reason, startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn, threadID: packet.threadID)

        // Encoding an error packet should not fail under any circumstances.
        data = try! errorPacket.encode()
    }
    catch {
        let errorPacket = LogPacket(errorWithReason: "Unknown failure encoding log packet", startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn, threadID: packet.threadID)

        // Encoding an error packet should not fail under any circumstances.
        data = try! errorPacket.encode()
    }
    
    sendData(data as NSData)
}
