//
//  SwiftExceptionSafety.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

// On Apple platforms, SwiftExceptionSafety is used to turn ObjC-based throws into an exception return which Swift code then can handle without crashing
// On non-Apple platforms, there is no ObjC runtime throwing things around, so provide an hollow stub to keep other code happy with minimal #ifs

class NSException {
    var description: String {
        return "NSException"
    }
}

class SwiftExceptionSafety {
    class func doTry (_ f: () -> ()) -> NSException? {
        f()
        return nil
    }
}

