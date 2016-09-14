//
//  NumberExtensions.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 6/15/15.
//  Copyright (c) 2015 StartApps. All rights reserved.
//

import Foundation

/********************************************************************************************************/
// MARK: Bool Extensions
/********************************************************************************************************/

public extension Bool {
    
    public mutating func toggle() -> Bool {
        self = !self
        return self
    }
    
}

/********************************************************************************************************/
 // MARK: Int Extensions
 /********************************************************************************************************/

public extension Int {
    
    public init?(string: String) {
        let nan = NSDecimalNumber.notANumber
        let decimal = NSDecimalNumber(string: string)
        guard decimal != nan else { return nil }
        self = decimal.intValue
    }
    
    public func nonZero() -> Int? {
        return (self != 0 ? self : nil)
    }
    
}

/********************************************************************************************************/
// MARK: NSDecimalNumber Extensions
/********************************************************************************************************/

public extension NSDecimalNumber {
    
    public convenience init?(fromString: String) {
        let nan = NSDecimalNumber.notANumber
        let decimal = NSDecimalNumber(string: fromString)
        guard decimal != nan else { return nil }
        self.init(string: fromString)
    }
    
    public var twoDecimalString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits  = 1
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter.string(from: self)!
    }
    
}

extension NSDecimalNumber: Comparable {}

public func ==(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .orderedSame
}

public func +=(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.adding(rhs)
}

public func -=(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.subtracting(rhs)
}

public func +(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.adding(rhs)
}

public func -(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.subtracting(rhs)
}

public func *(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.multiplying(by: rhs)
}

public func /(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.dividing(by: rhs)
}

public func ^(lhs: NSDecimalNumber, rhs: Int) -> NSDecimalNumber {
    return lhs.raising(toPower: rhs)
}

public func <(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

public prefix func -(value: NSDecimalNumber) -> NSDecimalNumber {
    return value.multiplying(by: NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true))
}
