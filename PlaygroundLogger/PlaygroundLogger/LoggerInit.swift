//
//  LoggerInit.swift
//  PlaygroundLogger
//
//  Copyright (c) 2014-2016 Apple Inc. All rights reserved.
//

/***
* Call this API before calling anything else in PlaygroundLogger
* If you fail to do that, then whatever fails to work is well deserved pain
***/
@_silgen_name("playground_logger_initialize") public
func playground_logger_initialize() {
    Swift._playgroundPrintHook = playground_logger_print_hook
    Woodchuck.chuck {
        return Woodchuck.LogEntry("PlaygroundLogger initialized correctly")
    }
}
