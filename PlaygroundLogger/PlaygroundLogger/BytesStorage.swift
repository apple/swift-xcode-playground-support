//
//  BytesStorage.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

import Foundation

final class BytesStorage {
	let data: NSData // hold on to the NSData so it doesn't go away from under us
    let bytes: UnsafeMutablePointer<UInt8> // but a pointer is good enough to actually index bytes by
	var index: Int
	
	init(_ _bytes: NSData) {
        data = _bytes
        bytes = UnsafeMutablePointer(data.bytes)
        index = 0
	}
		
	func get() -> UInt8 {
        let i = index
        index += 1
		return bytes[i]
	}
	
	func peek() -> UInt8 {
		return bytes[index]
	}
	
	func eof() -> Bool {
		return index >= count
	}
	
    var count: Int {
        get { return data.length }
	}
	
	subscript (i: UInt64) -> UInt8 {
		get {
	    	return bytes[index+Int(i)]
		}
	}
	
	func has(_ nBytes: UInt64) -> Bool {
		return (index+Int(nBytes) <= count)
	}
    
    func dumpBytes() {
        count.doFor { (idx: Int) -> () in
            let byte : UInt8 = self.bytes[idx]
            print("\(byte) ", terminator: "")
        }
        print("")
    }
    
    func subset(len: UInt64, consume: Bool) -> BytesStorage {
        let copydata = NSData(bytesNoCopy:bytes+index, length: Int(len), freeWhenDone: false)
        if consume {
            index = index + Int(len)
        }
        return BytesStorage(copydata)
    }
}
