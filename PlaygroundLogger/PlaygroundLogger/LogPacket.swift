//===--- LogPacket.swift --------------------------------------------------===//
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

import Darwin

struct LogPacket {
    var startLine: Int
    var endLine: Int
    var startColumn: Int
    var endColumn: Int
    
    var threadID: String
    
    var logEntry: LogEntry
}

private let stringTypeName = normalizedName(of: String.self)

extension LogPacket {
    private init(logEntry: LogEntry, startLine: Int, endLine: Int, startColumn: Int, endColumn: Int, threadID: String?) {
        self.startLine = startLine
        self.endLine = endLine
        self.startColumn = startColumn
        self.endColumn = endColumn
        self.threadID = threadID ?? "\(pthread_mach_thread_np(pthread_self()))"
        self.logEntry = logEntry
    }
    
    init(describingResult result: Any, named name: String, withPolicy policy: LogPolicy, startLine: Int, endLine: Int, startColumn: Int, endColumn: Int, threadID: String? = nil) {
        let logEntry: LogEntry
        do {
            logEntry = try LogEntry(describing: result, name: name, policy: policy)
        }
        catch let LoggingError.failedToGenerateOpaqueRepresentation(reason) {
            logEntry = .error(reason: reason)
        }
        catch LoggingError.encodingFailure {
            fatalError("Encoding failures should not be encountered while generating LogEntry values")
        }
        catch let LoggingError.otherFailure(reason) {
            logEntry = .error(reason: reason)
        }
        catch {
            logEntry = .error(reason: "Unknown error encountered when generating log entry")
        }
        
        self = .init(logEntry: logEntry, startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn, threadID: threadID)
    }
    
    init(scopeEntryWithStartLine startLine: Int, endLine: Int, startColumn: Int, endColumn: Int, threadID: String? = nil) {
        self = .init(logEntry: .scopeEntry, startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn, threadID: threadID)
    }
    
    init(scopeExitWithStartLine startLine: Int, endLine: Int, startColumn: Int, endColumn: Int, threadID: String? = nil) {
        self = .init(logEntry: .scopeExit, startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn, threadID: threadID)
    }
    
    init(gapWithStartLine startLine: Int, endLine: Int, startColumn: Int, endColumn: Int, threadID: String? = nil) {
        self = .init(logEntry: .gap, startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn, threadID: threadID)
    }
    
    init(errorWithReason errorReason: String, startLine: Int, endLine: Int, startColumn: Int, endColumn: Int, threadID: String? = nil) {
        self = .init(logEntry: .error(reason: errorReason), startLine: startLine, endLine: endLine, startColumn: startColumn, endColumn: endColumn, threadID: threadID)
    }
    
    init(printedString: String, startLine: Int, endLine: Int, startColumn: Int, endColumn: Int, threadID: String? = nil) {
        // TODO: This should log something more specific than a generic opaque log entry, but the current PlaygroundLogger format does not support anything else.
        self = .init(logEntry: .opaque(name: "",
                                       typeName: stringTypeName,
                                       summary: printedString,
                                       preferBriefSummary: false,
                                       representation: printedString),
                     startLine: startLine,
                     endLine: endLine,
                     startColumn: startColumn,
                     endColumn: endColumn,
                     threadID: threadID)
    }
}
