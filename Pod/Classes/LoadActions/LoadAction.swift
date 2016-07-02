//
//  LoadAction.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 9/17/15.
//  Copyright (c) 2014 StartApps. All rights reserved.
//  Version: 1.0
//

import Foundation

public class LoadAction<T>: LoadActionType {
    
    //public typealias T = U
    
    public typealias LoadResultType     = Result<T, ErrorType>
    public typealias LoadResultClosure  = (result: LoadResultType) -> Void
    public typealias LoadResult         = (forced: Bool, completion: LoadResultClosure) -> Void
    
    public var updatedProperties: Set<LoadActionProperties> = []
    public var delegates: [LoadActionDelegate] = []
    
    public var status: LoadingStatus = .Ready {
        didSet { updatedProperties.insert(.Status) }
    }
    public var error: ErrorType? {
        didSet { updatedProperties.insert(.Error) }
    }
    public var value: T? {
        didSet { updatedProperties.insert(.Value); date = NSDate() }
    }
    public var date: NSDate? {
        didSet { updatedProperties.insert(.Date) }
    }
    
    public var loadClosure: LoadResult!
    
    /**
    Loads value giving the option of paging or loading new.
    
    - parameter forced: If true forces main load
    - parameter completion: Closure called when operation finished
    */
    public func load(forced forced: Bool, completion: LoadResultClosure?) {
        print(owner: "LoadAction", items: "Load Began", level: .Info)
        
        // Adjust loading status to loading kind
        status = .Loading
        sendDelegateUpdates()
        
        // Load value
        loadClosure(forced: forced) { (result) -> () in
            
            switch result {
            case .Failure(let error):
                print(owner: "LoadAction", items: "Loaded = Error \(error)", level: .Error)
                self.error = error
            case .Success(let loadedValue):
                print(owner: "LoadAction", items: "Loaded = Value \(loadedValue)", level: .Info)
                self.value = loadedValue
            }
            
            // Adjust loading status to loaded kind and call completion
            self.status = .Ready
            self.sendDelegateUpdates()
            completion?(result: result)
        }
        
    }
    
    public func loadAny(forced forced: Bool, completion: ((result: Result<Any, ErrorType>) -> Void)?) {
        load(forced: forced) { (resultGeneric) -> Void in
            switch resultGeneric {
            case .Success(let loadedValue):
                completion?(result: Result.Success(loadedValue))
            case .Failure(let error):
                completion?(result: Result.Failure(error))
            }
        }
    }
    
    /**
    Quick initializer with all closures
    
    - parameter load: Closure to load from web, must call result closure when finished
    - parameter delegates: Array containing objects that react to updated value
    */
    public init(
        load:       LoadResult,
        delegates: [LoadActionDelegate] = [],
        dummy:      (() -> ())? = nil)
    {
        self.loadClosure    = load
        self.delegates      = delegates
    }
    
}

