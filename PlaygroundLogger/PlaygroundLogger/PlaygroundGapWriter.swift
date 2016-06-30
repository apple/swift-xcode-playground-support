//
//  PlaygroundGapWriter.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

class PlaygroundGapWriter : PlaygroundWriter {
    func encode(gap: String, range: SourceRange) {
        encode(header: range)
        stream.write(gap) // this might not mean a lot for a gap.. but anyway, it's not forbidden
        stream.write(PlaygroundRepresentation.Gap.toBytes())
    }
}

