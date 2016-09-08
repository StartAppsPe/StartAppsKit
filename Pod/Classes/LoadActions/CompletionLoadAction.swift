//
//  CompletionLoadAction.swift
//  ULima
//
//  Created by Gabriel Lanata on 8/9/16.
//  Copyright © 2016 Universidad de Lima. All rights reserved.
//

import Foundation

public class CompletionLoadAction<A, B>: LoadAction<B> {
    
    public typealias QuickCompletionResult = (loadedValue: A, loadAction: LoadAction<A>) -> LoadAction<B>
    
    public var completionClosure: QuickCompletionResult
    
    public var baseLoadAction: LoadAction<A>
    
    private func loadInner(completion completion: LoadResultClosure) {
        print(owner: "LoadAction[Completion]", items: "Load Began", level: .Debug)
        baseLoadAction.load() { (result) in
            switch result {
            case .Failure(let error):
                print(owner: "LoadAction[Completion]", items: "Load Failure Base", level: .Debug)
                completion(result: .Failure(error))
            case .Success(let loadedValue):
                self.completionClosure(loadedValue: loadedValue, loadAction: self.baseLoadAction).load(completion: { (result) in
                    switch result {
                    case .Failure(let error):
                        print(owner: "LoadAction[Completion]", items: "Load Failure", level: .Debug)
                        completion(result: .Failure(error))
                    case .Success(let loadedValue2):
                        print(owner: "LoadAction[Completion]", items: "Load Success", level: .Debug)
                        completion(result: .Success(loadedValue2))
                    }
                })
            }
        }
    }
    
    public init(
        baseLoadAction: LoadAction<A>,
        completion:     QuickCompletionResult,
        dummy:          (() -> ())? = nil
        )
    {
        self.baseLoadAction = baseLoadAction
        self.completionClosure = completion
        super.init(
            load:      { _ in }
        )
        self.loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
    }
    
}


public extension LoadAction {
    
    public func completion<B>(completionClosure: CompletionLoadAction<T, B>.QuickCompletionResult) -> CompletionLoadAction<T, B> {
        return CompletionLoadAction<T, B>(
            baseLoadAction: self,
            completion: completionClosure
        )
    }
    
}