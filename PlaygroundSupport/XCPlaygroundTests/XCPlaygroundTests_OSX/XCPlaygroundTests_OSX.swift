//
//  XCPlaygroundTests_OSX.swift
//  XCPlaygroundTests_OSX
//
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import XCTest
import XCPlayground

class XCPlaygroundTests_OSX: XCPlaygroundCommonTests {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        XCPlaygroundPage.currentPage.liveView = nil
        super.tearDown()
    }
    
    func testLiveViewWithView() {
        let view = NSView()
        
        // Test setting to a view
        expectation(forNotification: "XCPlaygroundPageLiveViewDidChangeNotification", object: XCPlaygroundPage.currentPage) { (notification) in
            guard let userInfoView = notification.userInfo?["XCPlaygroundPageLiveView"] as? NSView else { return false }
            guard notification.userInfo?["XCPlaygroundPageLiveViewController"] == nil else { return false }
            XCTAssertEqual(userInfoView, view)
            return true
        }
        XCPlaygroundPage.currentPage.liveView = view
        waitForExpectations(withTimeout: 0.1, handler: nil)
        
        // Test setting back to nil
        expectation(forNotification: "XCPlaygroundPageLiveViewDidChangeNotification", object: XCPlaygroundPage.currentPage) { (notification) in
            guard notification.userInfo?["XCPlaygroundPageLiveView"] == nil else { return false }
            guard notification.userInfo?["XCPlaygroundPageLiveViewController"] == nil else { return false }
            return true
        }
        XCPlaygroundPage.currentPage.liveView = nil
        waitForExpectations(withTimeout: 0.1, handler: nil)
    }
    
    func testLiveViewWithViewController() {
        let viewController = NSViewController()
        
        // Test setting to a view controller
        expectation(forNotification: "XCPlaygroundPageLiveViewDidChangeNotification", object: XCPlaygroundPage.currentPage) { (notification) in
            guard let userInfoViewController = notification.userInfo?["XCPlaygroundPageLiveViewController"] as? NSViewController else { return false }
            guard notification.userInfo?["XCPlaygroundPageLiveView"] == nil else { return false }
            XCTAssertEqual(userInfoViewController, viewController)
            return true
        }
        XCPlaygroundPage.currentPage.liveView = viewController
        waitForExpectations(withTimeout: 0.1, handler: nil)
        
        // Test setting back to nil
        expectation(forNotification: "XCPlaygroundPageLiveViewDidChangeNotification", object: XCPlaygroundPage.currentPage) { (notification) in
            guard notification.userInfo?["XCPlaygroundPageLiveView"] == nil else { return false }
            guard notification.userInfo?["XCPlaygroundPageLiveViewController"] == nil else { return false }
            return true
        }
        XCPlaygroundPage.currentPage.liveView = nil
        waitForExpectations(withTimeout: 0.1, handler: nil)
    }
    
    // MARK: Deprecated Functions
    
    func testXCPShowView() {
        let view = NSView()
        expectation(forNotification: "XCPlaygroundPageLiveViewDidChangeNotification", object: XCPlaygroundPage.currentPage) { (notification) in
            guard let userInfoView = notification.userInfo?["XCPlaygroundPageLiveView"] as? NSView else { return false }
            XCTAssertEqual(userInfoView, view)
            return true
        }
        XCPShowView(identifier: "", view: view)
        waitForExpectations(withTimeout: 0.1, handler: nil)
    }
    
    
}
