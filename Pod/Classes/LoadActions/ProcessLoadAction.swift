//
//  ProcessLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 24/8/16.
//
//

import Foundation

public class ProcessLoadAction<A, B>: LoadAction<B> {
    
    public typealias QuickProcessResult = (loadedValue: A, loadAction: LoadAction<A>) -> B
    
    public typealias ProcessResultType    = Result<B, ErrorType>
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
            if let loadedValue = loadedValue as? B {
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
        process:        ProcessResult,
        dummy:          (() -> ())? = nil)
    {
        self.baseLoadAction = baseLoadAction
        self.processClosure = process
        super.init(
            load:      { _ in }
        )
        self.loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
    }
    
}

public extension LoadAction {
    
    public func process<B>(processClosure: ProcessLoadAction<T, B>.QuickProcessResult, dummy: (() -> ())? = nil) -> ProcessLoadAction<T, B> {
        return ProcessLoadAction<T, B>(
            baseLoadAction: self,
            process: { (loadedValue, completion) in
                let processedValue = processClosure(loadedValue: loadedValue, loadAction: self)
                completion(result: .Success(processedValue))
            }
        )
    }
    
}