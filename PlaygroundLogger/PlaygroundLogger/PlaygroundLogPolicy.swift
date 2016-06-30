//
//  PlaygroundLogPolicy.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

public typealias LoggerClosure = () -> ()

private
func playgroundLogWithPolicy(_ policy: LoggingLevelPolicy, _ f : LoggerClosure) {
    LoggingPolicyStack.get().push(policy)
    f()
    LoggingPolicyStack.get().pop()
}

public
func playground_log_default (_ f: LoggerClosure) {
    playgroundLogWithPolicy(LoggingLevelPolicy_Default(), f)
}

public
func playground_log_never (_ f : LoggerClosure) {
    playgroundLogWithPolicy(LoggingLevelPolicy_Never(), f)
}

public
func playground_log_adaptive (_ f : LoggerClosure) {
    playgroundLogWithPolicy(LoggingLevelPolicy_Adaptive(), f)
}
