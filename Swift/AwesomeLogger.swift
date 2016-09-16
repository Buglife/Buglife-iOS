//
//  AwesomeLogger.swift
//  Buglife
//
//  Copyright © 2016 Buglife, Inc. All rights reserved.
//

import Buglife

public func life_log(type: LIFEAwesomeLogType, @autoclosure message: () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    let async: Bool = (type != .Error)
    LIFEAwesomeLogger.sharedLogger().log(async, type: type, file: "\(file)", function: "\(function)", line: line, message: message())
}

public func life_log_debug(@autoclosure message: () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    life_log(.Debug, message: message, file: file, function: function, line: line)
}

public func life_log_info(@autoclosure message: () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    life_log(.Info, message: message, file: file, function: function, line: line)
}

public func life_log_error(@autoclosure message: () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    life_log(.Error, message: message, file: file, function: function, line: line)
}
