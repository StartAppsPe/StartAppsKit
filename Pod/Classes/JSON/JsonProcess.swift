//
//  JsonProcess.swift
//  Pods
//
//  Created by Gabriel Lanata on 2/10/16.
//
//

import Foundation
import SwiftyJSON

public func JsonProcess(_ loadedValue: NSData) throws -> JSON {
    var error: NSError?
    let loadedJson = JSON(data: loadedValue, error: &error)
    if let error = error {
        throw error
    } else {
        return loadedJson
    }
}

