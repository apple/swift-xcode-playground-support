//===--- LegacyEntrypoints.swift ------------------------------------------===//
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

/*
 LLDB contains references to the following functions:
 
     @_silgen_name ("playground_logger_initialize") func $builtin_logger_initialize() -> Void
     @_silgen_name ("playground_log_hidden") func $builtin_log_with_id<T>(_ object : T, _ name : String, _ id : Int, _ sl : Int, _ el : Int, _ sc : Int, _ ec: Int) -> AnyObject
     @_silgen_name ("playground_log_scope_entry") func $builtin_log_scope_entry(_ sl : Int, _ el : Int, _ sc : Int, _ ec: Int) -> AnyObject
     @_silgen_name ("playground_log_scope_exit") func $builtin_log_scope_exit(_ sl : Int, _ el : Int, _ sc : Int, _ ec: Int) -> AnyObject
     @_silgen_name ("playground_log_postprint") func $builtin_postPrint(_ sl : Int, _ el : Int, _ sc : Int, _ ec: Int) -> AnyObject
 
 where the `AnyObject` returned by each function is actually an `NSData` instance.
 
 To maintain compatibility with current and previous LLDB, we need to export these functions as well.
 */

@_silgen_name("playground_logger_initialize")
public func legacyInitializePlaygroundLogger() -> Void {
    Swift._playgroundPrintHook = printHook
    sendData = legacySendDataStub
}

fileprivate func legacySendDataStub(_: NSData) -> Void {
    fatalError("A legacy-initialized PlaygroundLogger should not use the sendData function pointer!")
}

@_silgen_name("playground_log_hidden")
public func legacyLog<T>(instance: T, name: String, id: Int, startLine: Int, endLine: Int, startColumn: Int, endColumn: Int) -> AnyObject? {
    guard !PGLGetThreadIsLogging() else { return nil }
    PGLSetThreadIsLogging(true)
    defer { PGLSetThreadIsLogging(false) }
    
    let packet = LogPacket(describingResult: instance, named: name, withPolicy: .default, startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn)

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
    
    return data as NSData
}

@_silgen_name ("playground_log_scope_entry")
public func legacyLogScopeEntry(startLine: Int, endLine: Int, startColumn: Int, endColumn: Int) -> AnyObject? {
    guard !PGLGetThreadIsLogging() else { return nil }
    PGLSetThreadIsLogging(true)
    defer { PGLSetThreadIsLogging(false) }
    
    let packet = LogPacket(scopeEntryWithStartLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn)

    // Encoding a scope entry packet should not fail under any circumstances.
    let data = try! packet.encode()

    return data as NSData
}

@_silgen_name ("playground_log_scope_exit")
public func legacyLogScopeExit(startLine: Int, endLine: Int, startColumn: Int, endColumn: Int) -> AnyObject? {
    guard !PGLGetThreadIsLogging() else { return nil }
    PGLSetThreadIsLogging(true)
    defer { PGLSetThreadIsLogging(false) }
    
    let packet = LogPacket(scopeExitWithStartLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn)

    // Encoding a scope exit packet should not fail under any circumstances.
    let data = try! packet.encode()

    return data as NSData
}

@_silgen_name ("playground_log_postprint")
public func legacyLogPostPrint(startLine: Int, endLine: Int, startColumn: Int, endColumn: Int) -> AnyObject? {
    guard !PGLGetThreadIsLogging() else { return nil }
    PGLSetThreadIsLogging(true)
    defer { PGLSetThreadIsLogging(false) }
    
    let printedString = Thread.current.threadDictionary[printedStringThreadDictionaryKey] as! String? ?? ""
    
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

    return data as NSData
}
