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
    
    public typealias LoadResultType     = Result<T, ErrorType>
    public typealias LoadResultClosure  = (result: LoadResultType) -> Void
    public typealias LoadResult   = (forced: Bool, completition: LoadResultClosure) -> Void
    
    public var updatedValues: Set<LoadActionValues> = []
    public var delegates: [LoadActionDelegate] = []
    
    public var status: LoadingStatus = .Ready {
        didSet { updatedValues.insert(.Status) }
    }
    public var error: ErrorType? {
        didSet { updatedValues.insert(.Error) }
    }
    public var data: T? {
        didSet { updatedValues.insert(.Data); date = NSDate() }
    }
    public var date: NSDate? {
        didSet { updatedValues.insert(.Date) }
    }
    
    public var loadClosure: LoadResult!
    
    /**
    Loads data giving the option of paging or loading new.
    
    - parameter forced: If true forces main load
    - parameter completition: Closure called when operation finished
    */
    public func load(forced forced: Bool, completition: LoadResultClosure?) {
        print(owner: "LoadAction", items: "Load Began", level: .Info)
        
        // Adjust loading status to loading kind
        status = .Loading
        sendDelegateUpdates()
        
        // Load data
        loadClosure(forced: forced) { (result) -> () in
            
            switch result {
            case .Failure(let error):
                print(owner: "LoadAction", items: "Loaded = Error \(error)", level: .Error)
                self.error = error
            case .Success(let loadedData):
                print(owner: "LoadAction", items: "Loaded = Data \((loadedData != nil ? "Found" : "Empty"))", level: .Info)
                self.data = loadedData
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
        load:       LoadResult,
        delegates: [LoadActionDelegate] = [],
        dummy:      (() -> ())? = nil)
    {
        self.loadClosure    = load
        self.delegates      = delegates
    }
    
}

