//
//  Regex.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

import Foundation

struct Regex {
    var rgx: RegularExpression
    
    init? (pattern: String) {
        do {
            let r = try RegularExpression(pattern: pattern, options: RegularExpression.Options.useUnicodeWordBoundaries)
            self.rgx = r
        } catch {
            return nil
        }
    }
    
    func replace(in: String, with: String) -> String {
        return rgx.stringByReplacingMatches(in: `in`, options: [], range: `in`.range, withTemplate: with)
    }
}
