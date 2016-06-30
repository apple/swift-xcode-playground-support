//
//  ExtensionBool.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

extension Bool : Serializable {
    func toBytes() -> [UInt8] {
        return [self ? 1 : 0]
    }
    
    init? (storage: BytesStorage) {
        let b = storage.get()
        if b == 1 { self = true }
        else if b == 0 { self = false }
        else { return nil }
    }
}
