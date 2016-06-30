//
//  Environment.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

import Foundation

final class Environment {
    class func get(variable: String, defaultValue: String? = nil) -> String? {
        let env = ProcessInfo.processInfo.environment
        if let index = env.index(forKey: variable) {
            return env[index].1
        }
        return defaultValue
    }
}
