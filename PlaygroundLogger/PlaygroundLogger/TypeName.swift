//===--- TypeName.swift ---------------------------------------------------===//
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

fileprivate let typeNameCache = PGLConcurrentMap()

private let swiftStdlibModuleNameRegex = try! NSRegularExpression(pattern: "(?<!\\.)\\b(Swift\\.)", options: [.useUnicodeWordBoundaries])

fileprivate func normalizeTypeName(_ typeName: String) -> String {
    return swiftStdlibModuleNameRegex.stringByReplacingMatches(in: typeName, options: [], range: NSRange(location: 0, length: typeName.utf16.count), withTemplate: "")
}

/// Returns the normalized name of the given `Any.Type`.
///
/// - note: This function caches type names, as normalization (and type name generation in general) can be expensive.
func normalizedName(of type: Any.Type) -> String {
    let key = Int(bitPattern: ObjectIdentifier(type))
    let (object, _) = typeNameCache.object(forKey: key, insertingIfNecessary: normalizeTypeName(_typeName(type)))
    return object as! String
}
