//
//  Logging.swift
//  Pods
//
//  Created by Gabriel Lanata on 9/17/15.
//  Copyright © 2015 StartApps. All rights reserved.
//

import Foundation

public var _PrintLevelCurrent = PrintLevel.Debug
public var _PrintIndentation1 = 25
public var _PrintIndentation2 = 100

public enum PrintLevel: Int {
    case None = 0, Fatal, Error, Warning, Info, Debug, Verbose
    public static var current: PrintLevel {
        set { _PrintLevelCurrent = newValue }
        get { return _PrintLevelCurrent }
    }
    public static var indentation1: Int {
        set { _PrintIndentation1 = newValue }
        get { return _PrintIndentation1 }
    }
    public static var indentation2: Int {
        set { _PrintIndentation2 = newValue }
        get { return _PrintIndentation2 }
    }
}

public func print(owner owner: String, items: Any..., separator: String = ", ", terminator: String = "\n", level: PrintLevel) {
    guard level.rawValue <= PrintLevel.current.rawValue else { return }
    var printString = "\(owner): "
    let indentationCount = max(PrintLevel.indentation1-printString.length, 0)
    let indentation = String(count: indentationCount, repeatedValue: " " as Character)
    var itemsString = String(items[0])
    for i in 1..<items.count { itemsString.appendContentsOf("\(separator)\(String(items[i]))") }
    printString.appendContentsOf("\(indentation)\(itemsString)")
    if level.rawValue <= PrintLevel.Warning.rawValue {
        let indentation2Count = max(PrintLevel.indentation2-printString.length, 0)
        let indentation2 = String(count: indentation2Count, repeatedValue: " " as Character)
        printString.appendContentsOf("\(indentation2)\(level)")
    }
    print(printString, terminator: terminator)
}