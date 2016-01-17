//
//  LoadAction.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 9/17/15.
//  Copyright (c) 2014 StartApps. All rights reserved.
//  Version: 1.0
//

import Foundation

public class LoadAction<U>: LoadActionType {
    
    public typealias T = U
    
    public typealias ResultType     = Result<T, ErrorType>
    public typealias ResultClosure  = (result: ResultType) -> Void
    public typealias LoadedResult   = (forced: Bool, completition: ResultClosure) -> Void
    
    public var updatedValues: [LoadActionValues] = []
    public var delegates:   [LoadActionDelegate] = []
    
    public var status: LoadingStatus = .Ready {
        didSet { updatedValues.appendUnique(.Status) }
    }
    public var error:  ErrorType? {
        didSet { updatedValues.appendUnique(.Error) }
    }
    public var data:   T? {
        didSet { updatedValues.appendUnique(.Data); date = NSDate() }
    }
    public var date:   NSDate? {
        didSet { updatedValues.appendUnique(.Date) }
    }
    
    public var loadClosure:  LoadedResult!
    
    /**
    Loads data giving the option of paging or loading new.
    
    - parameter forced: If true forces main load
    - parameter completition: Closure called when operation finished
    */
    public func load(forced forced: Bool, completition: ResultClosure?) {
        print(owner: "LoadAction", items: "Load Began", level: .Info)
        
        // Adjust loading status to loading kind
        status = .Loading
        sendDelegateUpdates()
        
        // Load data
        loadClosure(forced: forced) { (result) -> () in
            
            switch result {
            case .Success(let loadedData):
                print(owner: "LoadAction", items: "Loaded = Data \((loadedData != nil ? "Found" : "Empty"))", level: .Info)
                self.data = loadedData
            case .Failure(let error):
                print(owner: "LoadAction", items: "Loaded = Error \(error)", level: .Error)
                self.error = error
            }
            
            // Adjust loading status to loaded kind and call completition
            self.status = .Ready
            self.sendDelegateUpdates()
            completition?(result: result)
        }
        
    }
    
    public func loadAny(forced forced: Bool, completition: ((result: Result<Any, ErrorType>) -> Void)?) {
        load(forced: forced) { (resultGeneric) -> Void in
            switch resultGeneric {
            case .Success(let loadedData):
                completition?(result: Result.Success(loadedData))
            case .Failure(let error):
                completition?(result: Result.Failure(error))
            }
        }
    }
    
    /**
    Quick initializer with all closures
    
    - parameter load: Closure to load from web, must call result closure when finished
    - parameter delegates: Array containing objects that react to updated data
    */
    public init(
        load:       LoadedResult,
        delegates: [LoadActionDelegate] = [],
        dummy:      (() -> ())? = nil)
    {
        self.loadClosure = load
        self.delegates   = delegates
    }
    
}

