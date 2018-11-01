//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import XCTest
import PlaygroundSupport

#if os(macOS)
import AppKit

fileprivate typealias ViewType = NSView
fileprivate typealias ViewControllerType = NSViewController
#elseif os(iOS) || os(tvOS)
import UIKit

fileprivate typealias ViewType = UIView
fileprivate typealias ViewControllerType = UIViewController
#endif

// This is intentionally redefined here in the tests, as this string cannot change as it has clients which refer to it by the string value rather than by symbol.
fileprivate let playgroundPageLiveViewDidChangeNotification = Notification.Name(rawValue: "PlaygroundPageLiveViewDidChangeNotification")

class LiveViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        PlaygroundPage.current.liveView = nil
        super.tearDown()
    }

    func testLiveViewWithView() {
        let view = ViewType()

        // Test setting to a view
        expectation(forNotification: playgroundPageLiveViewDidChangeNotification, object: PlaygroundPage.current) { (notification) in
            guard let userInfoView = notification.userInfo?["PlaygroundPageLiveView"] as? ViewType else { return false }
            guard notification.userInfo?["PlaygroundPageLiveViewController"] == nil else { return false }
            XCTAssertEqual(userInfoView, view)
            return true
        }
        PlaygroundPage.current.liveView = view
        waitForExpectations(timeout: 0.1, handler: nil)

        // Test setting back to nil
        expectation(forNotification: playgroundPageLiveViewDidChangeNotification, object: PlaygroundPage.current) { (notification) in
            guard notification.userInfo?["PlaygroundPageLiveView"] == nil else { return false }
            guard notification.userInfo?["PlaygroundPageLiveViewController"] == nil else { return false }
            return true
        }
        PlaygroundPage.current.liveView = nil
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testLiveViewWithViewController() {
        let viewController = ViewControllerType()

        // Test setting to a view controller
        expectation(forNotification: playgroundPageLiveViewDidChangeNotification, object: PlaygroundPage.current) { (notification) in
            guard let userInfoViewController = notification.userInfo?["PlaygroundPageLiveViewController"] as? ViewControllerType else { return false }
            guard notification.userInfo?["PlaygroundPageLiveView"] == nil else { return false }
            XCTAssertEqual(userInfoViewController, viewController)
            return true
        }
        PlaygroundPage.current.liveView = viewController
        waitForExpectations(timeout: 0.1, handler: nil)

        // Test setting back to nil
        expectation(forNotification: playgroundPageLiveViewDidChangeNotification, object: PlaygroundPage.current) { (notification) in
            guard notification.userInfo?["PlaygroundPageLiveView"] == nil else { return false }
            guard notification.userInfo?["PlaygroundPageLiveViewController"] == nil else { return false }
            return true
        }
        PlaygroundPage.current.liveView = nil
        waitForExpectations(timeout: 0.1, handler: nil)
    }

}
