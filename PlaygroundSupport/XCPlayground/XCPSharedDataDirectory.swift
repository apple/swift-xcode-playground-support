//
//  XCPSharedDataDirectory.swift
//  XCPlayground
//
//  Copyright © 2016 Apple Inc. All rights reserved.
//

/// `XCPSharedDataDirectoryPath` has been deprecated. Use `XCPlaygroundSharedDataDirectoryURL` instead.
@available(*,deprecated,message:"Use 'PlaygroundSharedDataDirectoryURL' from the 'PlaygroundSupport' module instead")
public var XCPSharedDataDirectoryPath: String {
    return XCPlaygroundSharedDataDirectoryURL.path!
}
