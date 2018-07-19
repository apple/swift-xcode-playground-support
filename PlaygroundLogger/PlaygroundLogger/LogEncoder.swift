//===--- LogEncoder.swift -------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2017-2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation

final class LogEncoder {
    enum Format: UInt64 {
        case ten = 10
        
        static let current = Format.ten
    }
    
    private let buffer = NSMutableData()
    
    init() {}
    
    var encodedData: Data { return buffer as Data }
    
    func encode(byte: UInt8) {
        var byte = byte
        buffer.append(&byte, length: 1)
    }
    
    func encode(bytes: UnsafePointer<UInt8>, length: Int) {
        buffer.append(bytes, length: length)
    }
    
    func encode(number: UInt64, allowShortEncoding: Bool = true) {
        if allowShortEncoding && number < 255 {
            var byte = UInt8(number)
            buffer.append(&byte, length: 1)
            return
        }
        
        if allowShortEncoding {
            // If we allow the short encoding, but our number is too large, we need to include a marker.
            // If we don't allow the short encoding, we don't need to include the marker.
            var marker: UInt8 = 255
            buffer.append(&marker, length: 1)
        }
        
        var littleEndianNumber = number.littleEndian
        buffer.append(&littleEndianNumber, length: MemoryLayout<UInt64>.size)
    }
    
    func encode(string: String) {
        let utf8Count = string.utf8.count
        encode(number: UInt64(utf8Count))
        buffer.append(string, length: utf8Count)
    }
    
    func encode(boolean: Bool) {
        var byte: UInt8 = boolean ? 1 : 0
        buffer.append(&byte, length: 1)
    }
    
    func encode(float: Float) {
        var float = float
        buffer.append(&float, length: MemoryLayout<Float>.size)
    }
    
    func encode(double: Double) {
        var double = double
        buffer.append(&double, length: MemoryLayout<Double>.size)
    }
    
    func encode(data: Data) {
        buffer.append(data)
    }
}
