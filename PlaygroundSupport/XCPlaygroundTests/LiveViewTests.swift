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
import XCPlayground

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
let playgroundPageLiveViewDidChangeNotification = Notification.Name(rawValue: "XCPlaygroundPageLiveViewDidChangeNotification")

class LiveViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        XCPlaygroundPage.currentPage.liveView = nil
        super.tearDown()
    }

    func testLiveViewWithView() {
        let view = ViewType()

        // Test setting to a view
        expectation(forNotification: playgroundPageLiveViewDidChangeNotification, object: XCPlaygroundPage.currentPage) { (notification) in
            guard let userInfoView = notification.userInfo?["XCPlaygroundPageLiveView"] as? ViewType else { return false }
            guard notification.userInfo?["XCPlaygroundPageLiveViewController"] == nil else { return false }
            XCTAssertEqual(userInfoView, view)
            return true
        }
        XCPlaygroundPage.currentPage.liveView = view
        waitForExpectations(timeout: 0.1, handler: nil)

        // Test setting back to nil
        expectation(forNotification: playgroundPageLiveViewDidChangeNotification, object: XCPlaygroundPage.currentPage) { (notification) in
            guard notification.userInfo?["XCPlaygroundPageLiveView"] == nil else { return false }
            guard notification.userInfo?["XCPlaygroundPageLiveViewController"] == nil else { return false }
            return true
        }
        XCPlaygroundPage.currentPage.liveView = nil
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testLiveViewWithViewController() {
        let viewController = ViewControllerType()

        // Test setting to a view controller
        expectation(forNotification: playgroundPageLiveViewDidChangeNotification, object: XCPlaygroundPage.currentPage) { (notification) in
            guard let userInfoViewController = notification.userInfo?["XCPlaygroundPageLiveViewController"] as? ViewControllerType else { return false }
            guard notification.userInfo?["XCPlaygroundPageLiveView"] == nil else { return false }
            XCTAssertEqual(userInfoViewController, viewController)
            return true
        }
        XCPlaygroundPage.currentPage.liveView = viewController
        waitForExpectations(timeout: 0.1, handler: nil)

        // Test setting back to nil
        expectation(forNotification: playgroundPageLiveViewDidChangeNotification, object: XCPlaygroundPage.currentPage) { (notification) in
            guard notification.userInfo?["XCPlaygroundPageLiveView"] == nil else { return false }
            guard notification.userInfo?["XCPlaygroundPageLiveViewController"] == nil else { return false }
            return true
        }
        XCPlaygroundPage.currentPage.liveView = nil
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    // MARK: Deprecated Functions

    func testXCPShowView() {
        let view = ViewType()
        expectation(forNotification: playgroundPageLiveViewDidChangeNotification, object: XCPlaygroundPage.currentPage) { (notification) in
            guard let userInfoView = notification.userInfo?["XCPlaygroundPageLiveView"] as? ViewType else { return false }
            XCTAssertEqual(userInfoView, view)
            return true
        }
        XCPShowView(identifier: "", view: view)
        waitForExpectations(timeout: 0.1, handler: nil)
    }


}
