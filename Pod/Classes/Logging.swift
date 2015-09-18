//
//  Logging.swift
//  Pods
//
//  Created by Gabriel Lanata on 9/17/15.
//  Copyright © 2015 StartApps. All rights reserved.
//

import Foundation

public var _LogLevelCurrent = LogLevel.Warning
public var _LogIndentation  = 20

public enum LogLevel: Int {
    case None = 0, Fatal, Error, Warning, Info, Debug, Verbose
    public static var current: LogLevel {
        set { _LogLevelCurrent = newValue }
        get { return _LogLevelCurrent }
    }
    public static var indentation: Int {
        set { _LogIndentation = newValue }
        get { return _LogIndentation }
    }
}

public func print(owner owner: String, items: Any..., separator: String = ", ", terminator: String = "\n", level: LogLevel) {
    if level.rawValue <= LogLevel.current.rawValue {
        let indentationCount = max(LogLevel.indentation-owner.length(), 0)
        var indentation = ""
        for _ in 0..<indentationCount {
            indentation += " "
        }
        print("\(owner):\(indentation)", items, separator: separator, terminator: terminator)
    }
}