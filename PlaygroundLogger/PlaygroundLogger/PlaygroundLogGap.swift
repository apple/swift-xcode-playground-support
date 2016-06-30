//
//  PlaygroundLogGap.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

import Foundation

func playground_log_gap(_ name: String,
                        _ range: SourceRange) -> NSData {
    let encoder = PlaygroundGapWriter()
    encoder.encode(gap: name, range: range)
    return encoder.stream.data
}

