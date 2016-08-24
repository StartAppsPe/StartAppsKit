//
//  ProcessLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 24/8/16.
//
//

import Foundation

public class ProcessLoadAction<A, T>: LoadAction<T> {
    
    public typealias ProcessResultType    = Result<T, ErrorType>
    public typealias ProcessResultClosure = (result: ProcessResultType) -> Void
    public typealias ProcessResult        = (loadedValue: A, completion: ProcessResultClosure) -> Void
    
    public var processClosure: ProcessResult
    
    public var baseLoadAction: LoadAction<A>
    
    private func loadInner(completion completion: LoadResultClosure) {
        baseLoadAction.load() { (result) in
            switch result {
            case .Failure(let error):
                completion(result: Result.Failure(error))
            case .Success(let loadedValue):
                self.processClosure(loadedValue: loadedValue, completion: completion)
            }
        }
    }
    
    public class func automaticProcess() -> ProcessResult {
        return { (loadedValue: A, completion: ProcessResultClosure) in
            if let loadedValue = loadedValue as? T {
                completion(result: Result.Success(loadedValue))
            } else {
                let error = NSError(domain: "LoadAction[Process]", code: 432, description: "Could not automatically process value")
                completion(result: Result.Failure(error))
            }
        }
    }
    
    /**
     Quick initializer with all closures
     
     - parameter load: Closure to load from web, must call result closure when finished
     - parameter delegates: Array containing objects that react to updated data
     */
    public init(
        baseLoadAction: LoadAction<A>,
        process:        ProcessResult?,
        delegates:      [LoadActionDelegate] = [],
        dummy:          (() -> ())? = nil)
    {
        self.baseLoadAction = baseLoadAction
        if let processClosure = process {
            self.processClosure = processClosure
        } else {
            self.processClosure = ProcessLoadAction<A, T>.automaticProcess()
        }
        super.init(
            load:      { _ in },
            delegates: delegates
        )
        self.loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
    }
    
}