//
//  LoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 9/17/15.
//
//

import Foundation

public class LoadAction<U: CustomStringConvertible>: LoadActionType {
    
    public typealias T = U
    
    public typealias LoadedDataReturnType = (loadedData: T?) -> Bool
    public typealias LoadedResultType     = (result: LoadedDataErrorType) -> Void
    public typealias LoadedDataErrorType  = (loadedData: T?, error: ErrorType?) -> Void
    
    public var status: LoadingStatus = .Ready
    public var error:  ErrorType?
    public var data:   T?
    public var loadedDate: NSDate?
    
    public var limitOnce:                Bool = false
    public var shouldUpdateCacheClosure: LoadedDataReturnType?
    public var loadCacheClosure:         LoadedResultType?
    public var loadMainClosure:          LoadedResultType!
    
    public var delegates: [LoadActionDelegate]
    
    /**
    Loads new data forced replacing the previous stored data
    */
    public func loadNew() {
        load(forced: true) { (loadedData, error) -> () in
            // Do nothing
        }
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
        
        // Load data from cache first to populate the view, if cache is disabled it will pass through
        loadCache() { (loadedData, error) -> () in
            
            // Update data if not empty
            if let loadedData = loadedData {
                self.data = loadedData
            }
            
            // Check if should update cache
            let shouldUpdateCache = forced || self.shouldUpdateCacheClosure?(loadedData: self.data) ?? true
            if shouldUpdateCache {
                
                // Update delegates if did load data from cache before
                if let _ = loadedData {
                    self.delegates.performEach({ $0.loadActionUpdated(self) })
                }
                
                // Load data from main
                self.loadMain() { (loadedData, error) -> () in
                    
                    // Update data and error
                    self.data  = loadedData
                    self.error = error
                    if error == nil { self.loadedDate = NSDate() }
                    
                    // Adjust loading status to loaded kind and call completition
                    self.status = .Ready
                    self.delegates.performEach({ $0.loadActionUpdated(self) })
                    completition?(loadedData: self.data, error: self.error)
                }
                
            } else {
                
                // Adjust loading status to loaded kind and call completition
                self.status = .Ready
                self.delegates.performEach({ $0.loadActionUpdated(self) })
                completition?(loadedData: self.data, error: self.error)
                
            }
            
        }
        
    }
    
    /**
    Loads new data from cache and updates the action
    
    - parameter completition: Closure called when operation finished
    */
    private func loadCache(completition: LoadedDataErrorType?) {
        if let loadCacheClosure = loadCacheClosure {
            print(owner: "LoadAction", items: "Cache Load", level: .Info)
            loadCacheClosure() { (loadedData, error) -> () in
                if let error = error {
                    print(owner: "LoadAction", items: "Cache Loaded = Error \(error)", level: .Error)
                    completition?(loadedData: nil, error: error)
                } else {
                    print(owner: "LoadAction", items: "Cache Loaded = Length \(loadedData?.description.length())", level: .Info)
                    completition?(loadedData: loadedData, error: nil)
                }
            }
        } else {
            completition?(loadedData: nil, error: nil)
        }
    }
    
    /**
    Loads new data from main and updates the action
    
    - parameter completition: Closure called when operation finished
    */
    private func loadMain(completition: LoadedDataErrorType?) {
        print(owner: "LoadAction", items: "Main Load", level: .Info)
        loadMainClosure() { (loadedData, error) -> () in
            if let error = error {
                print(owner: "LoadAction", items: "Main Loaded = Error \(error)", level: .Error)
                completition?(loadedData: nil, error: error)
            } else {
                print(owner: "LoadAction", items: "Main Loaded = Length \(loadedData?.description.length())", level: .Info)
                completition?(loadedData: loadedData, error: nil)
            }
        }
    }
    
    /**
    Quick initializer with all closures
    
    - parameter loadOnce: Only load one time automatically (does allow reload when called specifically)
    - parameter allowCache: Load from cache before loading from web
    - parameter loadCache: Closure to load from cache, must call result closure when finished
    - parameter load: Closure to load from web, must call result closure when finished
    - parameter updateView: Closure to update the view when something has changed
    */
    public init(
        limitOnce:         Bool = false,
        shouldUpdateCache: LoadedDataReturnType? = nil,
        loadCache:         LoadedResultType? = nil,
        load:              LoadedResultType,
        delegates:        [LoadActionDelegate]? = nil,
        dummy:             (() -> ())? = nil)
    {
        self.limitOnce                = limitOnce
        self.shouldUpdateCacheClosure = shouldUpdateCache
        self.loadCacheClosure         = loadCache
        self.loadMainClosure          = load
        self.delegates                = delegates ?? []
    }
    
}

