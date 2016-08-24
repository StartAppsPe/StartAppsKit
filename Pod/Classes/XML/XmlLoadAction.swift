//
//  XmlLoadAction.swift
//  ULima
//
//  Created by Gabriel Lanata on 29/6/16.
//  Copyright © 2016 Universidad de Lima. All rights reserved.
//

import Foundation
import AEXML

public class XmlLoadAction: ProcessLoadAction<NSData, AEXMLElement> {
    
    private func processInner(loadedValue loadedValue: NSData, completion: ProcessResultClosure) {
        do {
            let loadedXml = try AEXMLDocument(xmlData: loadedValue)
            completion(result: Result.Success(loadedXml))
        } catch {
            completion(result: Result.Failure(error))
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
