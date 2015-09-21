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
    
    public typealias LoadedDataReturnType = (loadedData: T?) -> Bool
    public typealias LoadedResultType     = (forced: Bool, result: LoadedDataErrorType) -> Void
    public typealias LoadedDataErrorType  = (loadedData: T?, error: ErrorType?) -> Void
    
    public var status: LoadingStatus = .Ready
    public var error:  ErrorType?
    public var data:   T?
    public var loadedDate: NSDate?
    
    public var limitOnce:   Bool = false
    public var loadClosure: LoadedResultType!
    
    public var delegates: [LoadActionDelegate]
    
    /**
    Loads new data forced replacing the previous stored data
    */
    public func loadNew() {
        load(forced: true, completition: nil)
    }
    
    /**
    Loads data giving the option of paging or loading new.
    
    - parameter forced: If true forces main load
    - parameter completition: Closure called when operation finished
    */
    public func load(forced forced: Bool, completition: LoadedDataErrorType?) {
        print(owner: "LoadAction", items: "Load Called", level: .Info)
        
        // Bail if already processing
        guard status == .Ready else {
            delegates.performEach({ $0.loadActionUpdated(self) })
            completition?(loadedData: self.data, error: self.error)
            return
        }
        
        // Adjust loading status to loading kind
        status = .Loading
        delegates.performEach({ $0.loadActionUpdated(self) })
        
        // Load data from main
        loadClosure(forced: forced) { (loadedData, error) -> () in
            
            // Print messages
            if let error = error {
                print(owner: "LoadAction", items: "Loaded = Error \(error)", level: .Error)
            } else {
                let loadedSomething = (loadedData != nil ? "Found" : "Empty")
                print(owner: "LoadAction", items: "Loaded = Data \(loadedSomething)", level: .Info)
            }
            
            // Update data and error
            self.data  = loadedData
            self.error = error
            if error == nil { self.loadedDate = NSDate() }
            
            // Adjust loading status to loaded kind and call completition
            self.status = .Ready
            self.delegates.performEach({ $0.loadActionUpdated(self) })
            completition?(loadedData: self.data, error: self.error)
        }
        
    }
    
    /**
    Quick initializer with all closures
    
    - parameter limitOnce: Only load one time automatically (does allow reload when called specifically)
    - parameter shouldUpdateCache: Load from cache before loading from web
    - parameter loadCache: Closure to load from cache, must call result closure when finished
    - parameter load: Closure to load from web, must call result closure when finished
    - parameter delegates: Array containing objects that react to updated data
    */
    public init(
        limitOnce:         Bool = false,
        load:              LoadedResultType,
        delegates:        [LoadActionDelegate]? = nil,
        dummy:             (() -> ())? = nil)
    {
        self.limitOnce   = limitOnce
        self.loadClosure = load
        self.delegates   = delegates ?? []
    }
    
}

