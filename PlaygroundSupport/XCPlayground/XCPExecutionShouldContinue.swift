//
//  XCPExecutionShouldContinue.swift
//  XCPlayground
//
//  Copyright © 2016 Apple Inc. All rights reserved.
//

/// This function has been deprecated. Instead, set `PlaygroundPage.current.needsIndefiniteExecution` to the appropriate value.
@available(*,deprecated,message:"Set 'PlaygroundPage.current.needsIndefiniteExecution' from the 'PlaygroundSupport' module instead")
public func XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: Bool = true) {
    XCPlaygroundPage.currentPage.needsIndefiniteExecution = continueIndefinitely
}

/// This function has been deprecated. Instead, check `PlaygroundPage.current.needsIndefiniteExecution` to see if indefinite execution has been requested.
@available(*,deprecated,message:"Use 'PlaygroundPage.current.needsIndefiniteExecution' from the 'PlaygroundSupport' module instead")
public func XCPExecutionShouldContinueIndefinitely() -> Bool {
    return XCPlaygroundPage.currentPage.needsIndefiniteExecution
}
