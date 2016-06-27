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
        let nan = NSDecimalNumber.notANumber()
        let decimal = NSDecimalNumber(string: string)
        guard decimal != nan else { return nil }
        self = decimal.integerValue
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
        let nan = NSDecimalNumber.notANumber()
        let decimal = NSDecimalNumber(string: fromString)
        guard decimal != nan else { return nil }
        self.init(string: fromString)
    }
    
    public var twoDecimalString: String {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.minimumIntegerDigits  = 1
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter.stringFromNumber(self)!
    }
    
}

extension NSDecimalNumber: Comparable {}

public func ==(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .OrderedSame
}

public func +=(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.decimalNumberByAdding(rhs)
}

public func -=(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.decimalNumberBySubtracting(rhs)
}

public func +(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.decimalNumberByAdding(rhs)
}

public func -(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.decimalNumberBySubtracting(rhs)
}

public func *(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.decimalNumberByMultiplyingBy(rhs)
}

public func /(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.decimalNumberByDividingBy(rhs)
}

public func ^(lhs: NSDecimalNumber, rhs: Int) -> NSDecimalNumber {
    return lhs.decimalNumberByRaisingToPower(rhs)
}

public func <(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

public prefix func -(value: NSDecimalNumber) -> NSDecimalNumber {
    return value.decimalNumberByMultiplyingBy(NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true))
}
