//===--- Foundation.swift -------------------------------------------------===//
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

import Foundation

extension Date : CustomPlaygroundQuickLookable {
    private var summary: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: self)
    }
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(summary)
    }
}

extension NSDate : CustomPlaygroundQuickLookable {
    @nonobjc private var summary: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: self as Date)
    }
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(summary)
    }
}

extension NSRange : CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .range(Int64(location), Int64(length))
    }
}

extension NSString : CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(self as String)
    }
}

extension NSURL : CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        guard let str = absoluteString else { return .text("Unknown URL") }
        return .url(str)
    }
}

extension URL : CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .url(absoluteString)
    }
}
