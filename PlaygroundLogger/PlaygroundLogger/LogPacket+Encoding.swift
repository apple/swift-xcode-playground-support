//===--- LogPacket+Encoding.swift -----------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation

enum EncodingFormat {
    case ten
    
    static let current = EncodingFormat.ten
}

extension LogPacket {
    func encode(inFormat format: EncodingFormat = .current) -> Data {
        fatalError("Unimplemented function \(#function)")
    }
}
