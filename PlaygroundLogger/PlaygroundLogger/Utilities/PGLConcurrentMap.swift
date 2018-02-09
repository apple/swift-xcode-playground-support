//===--- PGLConcurrentMap.swift -------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

extension PGLConcurrentMap {
    func object(forKey key: Int, insertingIfNecessary object: @autoclosure () -> Any) -> (Any, didInsert: Bool) {
        var didInsert: ObjCBool = false
        let returnedObject = self.__object(forKey: key, insertingObjectProvidedByBlockIfNotPresent: object, didInsert: &didInsert)
        return (returnedObject, didInsert: didInsert.boolValue)
    }
}
