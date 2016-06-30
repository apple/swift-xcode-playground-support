//
//  XCPlaygroundCommonTests.swift
//  XCPlayground
//
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import XCTest
import XCPlayground

class XCPlaygroundCommonTests: XCTestCase {
    
    // MARK:
    
    /*
    func testFinishExecution() {
        expectation(forNotification: "XCPFinishExecution", object: XCPlaygroundPage.currentPage, handler: nil)
        XCPlaygroundPage.currentPage.finishExecution()
        waitForExpectationsWithTimeout(0.1, handler: nil)
    }
    */
    
    // MARK: Deprected XCPlaygroundPage
    
    func testPlaygroundPageCaptureValue() {
        let value = 321
        let identifier = "My Identifier 101"
        expectation(forNotification: "XCPCaptureValue", object: XCPlaygroundPage.currentPage) { (notification) in
            guard let userInfoValue = notification.userInfo?["value"] as? Int else { return false }
            XCTAssertEqual(userInfoValue, value)
            
            guard let userInfoIdentifier = notification.userInfo?["identifier"] as? String else { return false }
            XCTAssertEqual(userInfoIdentifier, identifier)
            
            return true
        }
        XCPlaygroundPage.currentPage.captureValue(value: value, withIdentifier: identifier)
        waitForExpectations(withTimeout: 0.1, handler: nil)
    }
    
    // MARK: Deprecated Functions
    
    func testLegacyCaptureValue() {
        let value = 123
        let identifier = "My Identifier"
        expectation(forNotification: "XCPCaptureValue", object: XCPlaygroundPage.currentPage) { (notification) in
            guard let userInfoValue = notification.userInfo?["value"] as? Int else { return false }
            XCTAssertEqual(userInfoValue, value)
            
            guard let userInfoIdentifier = notification.userInfo?["identifier"] as? String else { return false }
            XCTAssertEqual(userInfoIdentifier, identifier)
            return true
        }
        XCPCaptureValue(identifier: identifier, value: value)
        waitForExpectations(withTimeout: 0.1, handler: nil)
    }
    
    func testXCPExecutionShouldContinueIndefinitely() {
        XCTAssertEqual(XCPlaygroundPage.currentPage.needsIndefiniteExecution, XCPExecutionShouldContinueIndefinitely())
        XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: !XCPlaygroundPage.currentPage.needsIndefiniteExecution)
        XCTAssertEqual(XCPlaygroundPage.currentPage.needsIndefiniteExecution, XCPExecutionShouldContinueIndefinitely())
    }
    
}
