//===--- StandardLibrary.swift --------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014-2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

extension Float: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .float(self)
    }
}

extension Double: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .double(self)
    }
}

extension Bool: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .bool(self)
    }
}

extension String: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(self)
    }
}

extension Character: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(String(self))
    }
}

extension Unicode.Scalar: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .uInt(UInt64(self))
    }
}

extension Int: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .int(Int64(self))
    }
}

extension Int8: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .int(Int64(self))
    }
}

extension Int16: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .int(Int64(self))
    }
}

extension Int32: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .int(Int64(self))
    }
}

extension Int64: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .int(self)
    }
}

extension UInt: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .uInt(UInt64(self))
    }
}

extension UInt8: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .uInt(UInt64(self))
    }
}

extension UInt16: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .uInt(UInt64(self))
    }
}

extension UInt32: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .uInt(UInt64(self))
    }
}

extension UInt64: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .uInt(self)
    }
}

extension String.UnicodeScalarView: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(description)
    }
}

extension String.UTF16View: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(description)
    }
}

extension String.UTF8View: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(description)
    }
}

extension Substring: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return String(self).customPlaygroundQuickLook
    }
}

extension UnsafePointer: CustomPlaygroundQuickLookable {
    private var summary: String {
        let selfType = "UnsafePointer"
        let ptrValue = UInt64(bitPattern: Int64(Int(bitPattern: self)))
        return ptrValue == 0 ? "\(selfType)(nil)" : "\(selfType)(0x\(_uint64ToString(ptrValue, radix:16, uppercase:true)))"
    }
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(summary)
    }
}

extension UnsafeMutablePointer: CustomPlaygroundQuickLookable {
    private var summary: String {
        let selfType = "UnsafeMutablePointer"
        let ptrValue = UInt64(bitPattern: Int64(Int(bitPattern: self)))
        return ptrValue == 0 ? "\(selfType)(nil)" : "\(selfType)(0x\(_uint64ToString(ptrValue, radix:16, uppercase:true)))"
    }
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(summary)
    }
}

extension UnsafeRawPointer : CustomPlaygroundQuickLookable {
    private var summary: String {
        let selfType = "UnsafeRawPointer"
        let ptrValue = UInt64(bitPattern: Int64(Int(bitPattern: self)))
        return ptrValue == 0 ? "\(selfType)(nil)" : "\(selfType)(0x\(_uint64ToString(ptrValue, radix:16, uppercase:true)))"
    }
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(summary)
    }
}

extension UnsafeMutableRawPointer : CustomPlaygroundQuickLookable {
    private var summary: String {
        let selfType = "UnsafeMutableRawPointer"
        let ptrValue = UInt64(bitPattern: Int64(Int(bitPattern: self)))
        return ptrValue == 0 ? "\(selfType)(nil)" : "\(selfType)(0x\(_uint64ToString(ptrValue, radix:16, uppercase:true)))"
    }
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(summary)
    }
}

