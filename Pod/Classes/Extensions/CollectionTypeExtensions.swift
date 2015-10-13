//
//  ArrayExtensions.swift
//  StartApps
//
//  Created by Gabriel Lanata on 7/14/15.
//  Copyright (c) 2015 StartApps. All rights reserved.
//

public extension CollectionType {
    
    public func performEach(action: (Self.Generator.Element) -> Void) {
        for obj in self { action(obj) }
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
        var rtn: [Self.Generator.Element] = []
        for x in self {
            if !rtn.contains(x) {
                rtn.append(x)
            }
        }
        return rtn
    }
}

public extension RangeReplaceableCollectionType where Generator.Element: Equatable {
    
    mutating func appendUnique(newElement: Self.Generator.Element) {
        if !contains(newElement) {
            append(newElement)
        }
    }
    
    mutating func remove(element: Self.Generator.Element) {
        if let index = indexOf(element) {
            self.removeAtIndex(index)
        }
    }
    
}