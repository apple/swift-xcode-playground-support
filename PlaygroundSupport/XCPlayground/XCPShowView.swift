//
//  XCPShowView.swift
//  XCPlayground
//
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

/// `XCPShowView` has been deprecated. Instead, set `XCPlaygroundPage.liveView` to the appropriate value.
#if os(OSX)
@available(*,deprecated,message:"Set 'PlaygroundPage.current.liveView' from the 'PlaygroundSupport' module instead")
public func XCPShowView(identifier: String, view: NSView) {
    guard XCPlaygroundPage.currentPage.liveView == nil else { fatalError("Presenting multiple live views is not supported") }
    XCPlaygroundPage.currentPage.liveView = view
}
#elseif os(iOS) || os(tvOS)
@available(*,deprecated,message:"Set 'PlaygroundPage.current.liveView' from the 'PlaygroundSupport' module instead")
public func XCPShowView(identifier: String, view: UIView) {
    guard XCPlaygroundPage.currentPage.liveView == nil else { fatalError("Presenting multiple live views is not supported") }
    XCPlaygroundPage.currentPage.liveView = view
}
#endif
