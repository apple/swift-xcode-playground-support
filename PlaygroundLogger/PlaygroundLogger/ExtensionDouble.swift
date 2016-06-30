//
//  ExtensionDouble.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

extension Double : Serializable {
    
    func toBytes() -> [UInt8] {
        var udPtr = UnsafeMutablePointer<Double>(allocatingCapacity: 1)
        defer { udPtr.deallocateCapacity(1) }
        udPtr.pointee = self
        let ubPtr = UnsafeMutablePointer<UInt8>(udPtr)
        var arr = Array<UInt8>(repeating: 0, count: 8)
        8.doFor {
            arr[$0] = ubPtr[$0]
        }
        return arr
    }
    
    
    init? (storage: BytesStorage) {
        var ubPtr = UnsafeMutablePointer<UInt8>(allocatingCapacity: 8)
        defer { ubPtr.deallocateCapacity(8) }
        8.doFor {
            ubPtr[$0] = storage.get()
        }
        let udPtr = UnsafeMutablePointer<Double>(ubPtr)
        self = udPtr.pointee
    }
    
}

