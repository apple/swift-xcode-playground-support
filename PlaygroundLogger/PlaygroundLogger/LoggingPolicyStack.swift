//
//  LoggingPolicyStack.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

final class LoggingPolicyStack {
    class func get() -> LoggingPolicyStack {
        let tls = ThreadLocalStorage<LoggingPolicyStack>(key: "PlaygroundLogger_StackLoggingLevelPolicy")
        if let stk = tls.Data { return stk }
        let stk = LoggingPolicyStack()
        stk.push(LoggingLevelPolicy_Default()) // we always want a default policy at the bottom - an empty stack is a critical failure
        tls.Data = stk
        return stk
    }
    
    private var stack = Stack<LoggingLevelPolicy>()
    
    @discardableResult
    func push (_ p: LoggingLevelPolicy) -> LoggingPolicyStack {
        stack.push(p)
        return self
    }
    
    @discardableResult
    func pop() -> LoggingPolicyStack {
        _ = stack.pop()
        return self
    }
    
    func peek() -> LoggingLevelPolicy {
        return stack.peek()
    }
}
