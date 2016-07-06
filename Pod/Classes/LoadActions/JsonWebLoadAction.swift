//
//  JsonWebLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 2/10/16.
//
//

import Foundation
import SwiftyJSON

public class JsonLoadAction<T>: ConvertLoadAction<NSData, JSON, T> {
    
    private func convertInner(loadedValue loadedValue: NSData, completion: ConvertResultClosure) {
        var error: NSError?
        let loadedJson = JSON(data: loadedValue, error: &error)
        if let error = error {
            completion(result: Result.Failure(error))
        } else {
            completion(result: Result.Success(loadedJson))
        }
    }
    
    public init(
        baseLoadAction: LoadAction<NSData>,
        process:        ProcessResult? = nil,
        delegates:      [LoadActionDelegate] = [],
        dummy:          (() -> ())? = nil)
    {
        super.init(
            baseLoadAction: baseLoadAction,
            convert: { _,_ in },
            process: process,
            delegates: delegates
        )
        self.convertClosure = { (loadedValue, completion) -> Void in
            self.convertInner(loadedValue: loadedValue, completion: completion)
        }
    }
    
}

