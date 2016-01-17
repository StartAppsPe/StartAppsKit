//
//  CacheLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 9/21/15.
//
//

import Foundation

public class CacheLoadAction<T>: LoadAction<T> {
    
    public typealias ResultType    = Result<T, ErrorType>
    public typealias ResultClosure = (result: ResultType) -> Void
    public typealias LoadedResult  = (forced: Bool, completition: ResultClosure) -> Void
    
    public typealias ShouldUpdateCacheClosure = (action: CacheLoadAction<T>) -> Bool
    
    public var shouldUpdateCacheClosure: ShouldUpdateCacheClosure?
    public var loadCacheClosure:         LoadedResult?
    public var loadMainClosure:          LoadedResult!
    
    /**
    Loads data giving the option of paging or loading new.
    
    - parameter forced: If true forces main load
    - parameter completition: Closure called when operation finished
    */
    private func loadInner(forced forced: Bool, completition: ResultClosure?) {
  
        // Load data from cache first to populate the view, if cache is disabled it will pass through
        loadCache(forced: forced) { (result) -> Void in
            var cacheError: ErrorType?
            
            switch result {
            case .Success(let loadedData):
                self.data = loadedData
            case .Failure(let error):
                cacheError = error
            }
            
            // Check if should update cache
            if forced || cacheError != nil || self.shouldUpdateCacheClosure?(action: self) ?? true {
                
                // Update delegates if did load data from cache before
                self.sendDelegateUpdates()
                
                // Load data from main
                self.loadMain(forced: forced) { (result) -> () in
                    completition?(result: result)
                }
                
            } else {
                completition?(result: Result.Success(self.data))
                
            }
            
        }
        
    }
    
    /**
    Loads new data from cache and updates the action
    
    - parameter completition: Closure called when operation finished
    */
    private func loadCache(forced forced: Bool, completition: ResultClosure?) {
        if let loadCacheClosure = loadCacheClosure {
            print(owner: "LoadAction[Cache]", items: "Cache Load", level: .Info)
            loadCacheClosure(forced: forced) { (result) -> Void in
                switch result {
                case .Success(let loadedData):
                    print(owner: "LoadAction[Cache]", items: "Cache Loaded = Data \((loadedData != nil ? "Found" : "Empty"))", level: .Info)
                    completition?(result: Result.Success(loadedData))
                case .Failure(let error):
                    print(owner: "LoadAction[Cache]", items: "Cache Loaded = Error \(error)", level: .Error)
                    completition?(result: Result.Failure(error))
                }
            }
        } else {
            completition?(result: Result.Success(self.data))
        }
    }
    
    /**
    Loads new data from main and updates the action
    
    - parameter completition: Closure called when operation finished
    */
    private func loadMain(forced forced: Bool, completition: ResultClosure?) {
        print(owner: "LoadAction", items: "Main Load", level: .Info)
        loadMainClosure(forced: forced) { (result) -> () in
            switch result {
            case .Success(let loadedData):
                print(owner: "LoadAction[Cache]", items: "Main Loaded = Data \((loadedData != nil ? "Found" : "Empty"))", level: .Info)
                completition?(result: Result.Success(loadedData))
            case .Failure(let error):
                print(owner: "LoadAction[Cache]", items: "Main Loaded = Error \(error)", level: .Error)
                completition?(result: Result.Failure(error))
            }
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
        shouldUpdateCache: ShouldUpdateCacheClosure? = nil,
        loadCache:         LoadedResult? = nil,
        load:              LoadedResult,
        delegates:        [LoadActionDelegate] = [],
        dummy:             (() -> ())? = nil)
    {
        self.shouldUpdateCacheClosure = shouldUpdateCache
        self.loadCacheClosure         = loadCache
        self.loadMainClosure          = load
        super.init(
            load: { (forced, result) -> Void in
            },
            delegates: delegates
        )
        loadClosure = { (forced, result) -> Void in
            self.loadInner(forced: forced, completition: result)
        }
    }
    
}

