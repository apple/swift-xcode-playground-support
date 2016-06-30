//
//  BytesStream.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

import Foundation

final class BytesStream {
    var data : NSMutableData
    
    init() {
        data = NSMutableData()
    }
    
    @discardableResult
    func write(_ x : UInt8) -> BytesStream {
        var ptr_x = UnsafeMutablePointer<UInt8>(allocatingCapacity: 1)
        defer { ptr_x.deallocateCapacity(1) }
        ptr_x.pointee = x
        data.append(ptr_x, length: 1)
        return self
    }
    
    @discardableResult
    func write(_ xs : [UInt8]) -> BytesStream {
        let ptr = xs
        let len = xs.count // we actually want the byte size here - this is xs.count*sizeof(elementType)-elementType==UInt8-->size=1, so here it is
        data.append(ptr, length: len)
        return self
    }
    
    // seems redundant, but is actually necessary
    // see rdar://19808714 and do not remove
    // without talking to me first
    @discardableResult
    func write(_ s : String) -> BytesStream {
        write(UInt64(s.byteLength))
        write(s.toBytes())
        return self
    }
    
    @discardableResult
    func write(_ bs : Serializable) -> BytesStream {
        write(bs.toBytes())
        return self
    }
    
    @discardableResult
    func write(_ d : NSData) -> BytesStream {
        return write(d as Data)
    }

    @discardableResult
    func write(_ d : Data) -> BytesStream {
        data.append(d)
        return self
    }
    
    var size: Int {
        return data.length
    }
}
