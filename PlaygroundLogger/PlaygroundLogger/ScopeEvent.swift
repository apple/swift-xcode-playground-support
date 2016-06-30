//
//  ScopeEvent.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

// this enum is not actually used to store and retrieve state
// all that matters is that the values in here are correctly
// translated to their PlaygroundRepresentation equivalents
enum ScopeEvent : UInt8, Equatable {
    case ScopeEntry = 9
    case ScopeExit = 10
    
    var hashValue : Int {
        return Int(self.rawValue)
    }
}

extension PlaygroundRepresentation {
    init (scope: ScopeEvent) {
        switch scope {
        case .ScopeEntry: self = .ScopeEntry
        case .ScopeExit: self = .ScopeExit
        }
    }
}
