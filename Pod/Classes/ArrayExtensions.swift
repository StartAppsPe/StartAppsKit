//
//  ArrayExtensions.swift
//  StartApps
//
//  Created by Gabriel Lanata on 7/14/15.
//  Copyright (c) 2015 StartApps. All rights reserved.
//

public extension Array {
    
    public func find(isElement: (Element) -> Bool) -> Element? {
        return filter(isElement).first
    }
    
    public func performEach(action: (Element) -> Void) {
        for obj in self { action(obj) }
    }
    
}
