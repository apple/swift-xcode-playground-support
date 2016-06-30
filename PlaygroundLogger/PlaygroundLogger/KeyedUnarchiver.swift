//
//  LoggerUnarchiver.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

import Foundation

final class LoggerUnarchiver {
   var unarchiver : NSKeyedUnarchiver
   let storage : BytesStorage
   
   init(_ stg : BytesStorage) {
      storage = stg
      unarchiver = NSKeyedUnarchiver(forReadingWith: NSData(bytes: storage.bytes + storage.index, length: storage.count - storage.index) as Data)
   }
   
   func get(double: String) -> Double {
    return unarchiver.decodeDouble(forKey: double)
   }
   
   func get(bool : String) -> Bool {
    return unarchiver.decodeBool(forKey: bool)
   }
   
   func get(int64 : String) -> Int64 {
    return unarchiver.decodeInt64(forKey: int64)
   }
   
   func get(uint64 : String) -> UInt64 {
    return UInt64(unarchiver.decodeInt64(forKey: uint64))
   }
   
   func get(object : String) -> AnyObject! {
    return unarchiver.decodeObject(forKey: object)
   }
   
   func has(_ key : String) -> Bool {
    switch unarchiver.decodeObject(forKey: key) {
        case nil: return false
        default: return true
    }
   }
}
