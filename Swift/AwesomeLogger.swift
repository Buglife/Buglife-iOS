//
//  AwesomeLogger.swift
//  Buglife
//
//  Copyright © 2016 Buglife, Inc. All rights reserved.
//

import Buglife

public func life_log(type: LIFEAwesomeLogType, message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    let async: Bool = (type != .error)
    LIFEAwesomeLogger.shared().log(async, type: type, file: "\(file)", function: "\(function)", line: line, message: message())
}

public func life_log_debug(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    life_log(type: .debug, message: message, file: file, function: function, line: line)
}

public func life_log_info(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    life_log(type: .info, message: message, file: file, function: function, line: line)
}

public func life_log_error(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    life_log(type: .error, message: message, file: file, function: function, line: line)
}
