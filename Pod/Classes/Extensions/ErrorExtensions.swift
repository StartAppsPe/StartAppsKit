//
//  ErrorExtensions.swift
//  ULima
//
//  Created by Gabriel Lanata on 8/25/15.
//  Copyright (c) 2015 Universidad de Lima. All rights reserved.
//

import Foundation

public extension NSError {
    
    public convenience init(domain: String, code: Int, description: String) {
        self.init(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey:description])
    }
   
}
