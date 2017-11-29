//===--- CIColor+CustomOpaqueLoggable.swift -------------------------------===//
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

import CoreImage

extension CIColor: CustomOpaqueLoggable {
    var opaqueRepresentation: LogEntry.OpaqueRepresentation {
        guard let color = CGColor(colorSpace: self.colorSpace, components: self.components) else {
            // TODO: don't crash in this case
            fatalError("Unable to convert CIColor to CGColor")
        }
        
        return color
    }
}
