//
//  PlaygroundScopeWriter.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

class PlaygroundScopeWriter : PlaygroundWriter {
    func encode(scope: ScopeEvent, range: SourceRange) {
        encode(header: range)
        stream.write("") // empty name field - maybe we can use it some day, just keep it consistent for now
        stream.write(PlaygroundRepresentation(scope: scope))
    }
}

