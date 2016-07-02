//
//  ArrayExtensions.swift
//  StartApps
//
//  Created by Gabriel Lanata on 7/14/15.
//  Copyright (c) 2015 StartApps. All rights reserved.
//

public extension CollectionType {
    
    public func performEach(action: (Self.Generator.Element) -> Void) {
        for element in self { action(element) }
    }
    
    @warn_unused_result
    public func find(isElement: (Self.Generator.Element) -> Bool) -> Self.Generator.Element? {
        if let index = indexOf(isElement) {
            return self[index]
        }
        return nil
    }
    
    @warn_unused_result
    public func shuffled() -> [Generator.Element] {
        var list = Array(self)
        list.shuffle()
        return list
    }
    
}

public extension CollectionType where Index == Int  {
    
    public var random: Self.Generator.Element? {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    
}

public extension MutableCollectionType where Index == Int  {
    
    public mutating func shuffle() {
        if count < 2 { return }
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
    
}

public extension CollectionType where Generator.Element : Equatable {
    
    @warn_unused_result
    public func distinct() -> [Self.Generator.Element] {
        var distinctElements: [Self.Generator.Element] = []
        for element in self {
            if !distinctElements.contains(element) {
                distinctElements.append(element)
            }
        }
        return distinctElements
    }
    
}

public extension Set {
    
    public mutating func toggle(element: Element) -> Bool {
        if contains(element) {
            remove(element)
            return false
        } else {
            insert(element)
            return true
        }
    }
    
}


public extension Array {
    
    public mutating func popFirst() -> Element? {
        if let first = first {
            removeAtIndex(0)
            return first
        }
        return nil
    }
    
}

public extension RangeReplaceableCollectionType where Generator.Element: Equatable {
    
    public mutating func appendUnique(element: Self.Generator.Element) {
        if !contains(element) {
            append(element)
        }
    }
    
    public mutating func appendIfExists(element: Self.Generator.Element?) {
        if let element = element {
            append(element)
        }
    }
    
    public mutating func appendUniqueIfExists(element: Self.Generator.Element?) {
        if let element = element where !contains(element) {
            append(element)
        }
    }
    
    public mutating func remove(element: Self.Generator.Element) {
        if let index = indexOf(element) {
            removeAtIndex(index)
        }
    }
    
    public mutating func toggle(element: Self.Generator.Element) {
        if let index = indexOf(element) {
            removeAtIndex(index)
        } else {
            append(element)
        }
    }
    
}

public extension Range where Element : Comparable {
    
    public func contains(element element: Element) -> Bool {
        return self ~= element
    }
    
    public func contains(range range: Range) -> Bool {
        return self ~= range
    }
    
}

@warn_unused_result
public func ~=<I : ForwardIndexType where I : Comparable>(pattern: Range<I>, value: Range<I>) -> Bool {
    return pattern ~= value.startIndex || pattern ~= value.endIndex || value ~= pattern.startIndex || value ~= pattern.endIndex
}
