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
