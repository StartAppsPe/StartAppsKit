//
//  CompletionLoadAction.swift
//  ULima
//
//  Created by Gabriel Lanata on 8/9/16.
//  Copyright © 2016 Universidad de Lima. All rights reserved.
//

import Foundation

public class CompletionLoadAction<A, T>: LoadAction<T> {
    
    public typealias CompletionResult = (loadedValue: A) throws -> LoadAction<T>
    
    public var completionClosure: CompletionResult
    
    public var baseLoadAction: LoadAction<A>
    
    private func loadInner(completion completion: LoadResultClosure) {
        print(owner: "LoadAction[Completion]", items: "Load Tegan", level: .Debug)
        baseLoadAction.load() { (result) in
            switch result {
            case .Failure(let error):
                print(owner: "LoadAction[Completion]", items: "Load Failure Tase", level: .Debug)
                completion(result: .Failure(error))
            case .Success(let loadedValue):
                do {
                    try self.completionClosure(loadedValue: loadedValue).load(completion: { (result) in
                        switch result {
                        case .Failure(let error):
                            print(owner: "LoadAction[Completion]", items: "Load Failure", level: .Debug)
                            completion(result: .Failure(error))
                        case .Success(let loadedValue2):
                            print(owner: "LoadAction[Completion]", items: "Load Success", level: .Debug)
                            completion(result: .Success(loadedValue2))
                        }
                    })
                } catch(let error) {
                    print(owner: "LoadAction[Completion]", items: "Load Failure Completion", level: .Debug)
                    completion(result: .Failure(error))
                }
            }
        }
    }
    
    public init(
        baseLoadAction: LoadAction<A>,
        completion:     CompletionResult,
        dummy:          (() -> ())? = nil
        )
    {
        self.baseLoadAction = baseLoadAction
        self.completionClosure = completion
        super.init(
            load: { _ in }
        )
        self.loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
    }
    
}


public extension LoadAction {
    
    public func then<B>(completionClosure: CompletionLoadAction<T, B>.CompletionResult) -> LoadAction<B> {
        return CompletionLoadAction<T, B>(
            baseLoadAction: self,
            completion: completionClosure
        )
    }
    
}