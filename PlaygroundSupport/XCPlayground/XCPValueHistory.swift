//
//  XCPValueHistory.swift
//  XCPlayground
//
//  Copyright © 2016 Apple Inc. All rights reserved.
//

/// This function has been deprecated.
@available(*,deprecated) public func XCPCaptureValue<T>(identifier: String, value: T) {
    XCPlaygroundPage.currentPage.captureValue(value: value, withIdentifier: identifier)
}
