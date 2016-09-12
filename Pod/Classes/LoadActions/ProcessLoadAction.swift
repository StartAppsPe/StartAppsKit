//
//  ProcessLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 24/8/16.
//
//

import Foundation

public class ProcessLoadAction<A, T>: LoadAction<T> {
    
    public typealias ProcessResult = (loadedValue: A) throws -> T
    
    public var processClosure: ProcessResult
    
    public var baseLoadAction: LoadAction<A>
    
    private func loadInner(completion completion: LoadResultClosure) {
        baseLoadAction.load() { (result) in
            switch result {
            case .Failure(let error):
                completion(result: .Failure(error))
            case .Success(let loadedValue):
                do {
                    let processedValue = try self.processClosure(loadedValue: loadedValue)
                    completion(result: .Success(processedValue))
                } catch(let error) {
                    completion(result: .Failure(error))
                }
            }
        }
    }
    
    public init(
        baseLoadAction: LoadAction<A>,
        process:        ProcessResult,
        dummy:          (() -> ())? = nil)
    {
        self.baseLoadAction = baseLoadAction
        self.processClosure = process
        super.init(
            load: { _ in }
        )
        self.loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
    }
    
}

public extension ProcessLoadAction {
    
    public class func automaticProcess(loadedValue loadedValue: A) throws -> T {
        guard let loadedValue = loadedValue as? T else {
            throw NSError(domain: "LoadAction[Process]", code: 432, description: "Could not automatically process value")
        }
        return loadedValue
    }
    
}

public extension LoadAction {
    
    public func then<B>(processClosure: ProcessLoadAction<T, B>.ProcessResult) -> LoadAction<B> {
        return ProcessLoadAction<T, B>(
            baseLoadAction: self,
            process: processClosure
        )
    }
    
}