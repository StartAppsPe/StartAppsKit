//
//  JsonWebLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 2/10/16.
//
//

import Foundation
import SwiftyJSON

public class JsonLoadAction: ProcessLoadAction<NSData, JSON> {
    
    private func processInner(loadedValue loadedValue: NSData, completion: ProcessResultClosure) {
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
        delegates:      [LoadActionDelegate] = [],
        dummy:          (() -> ())? = nil)
    {
        super.init(
            baseLoadAction: baseLoadAction,
            process: { _,_ in },
            delegates: delegates
        )
        self.processClosure = { (loadedValue, completion) -> Void in
            self.processInner(loadedValue: loadedValue, completion: completion)
        }
    }
    
}

