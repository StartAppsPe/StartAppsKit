//
//  CacheLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 9/21/15.
//
//

import Foundation

public class CacheLoadAction<U>: LoadAction<U> {
    
    public var shouldUpdateCacheClosure: LoadedDataReturnType?
    public var loadCacheClosure:         LoadedResultType?
    public var loadMainClosure:          LoadedResultType!
    
    /**
    Loads data giving the option of paging or loading new.
    
    - parameter forced: If true forces main load
    - parameter completition: Closure called when operation finished
    */
    private func loadInner(forced forced: Bool, completition: LoadedDataErrorType?) {
  
        // Load data from cache first to populate the view, if cache is disabled it will pass through
        loadCache(forced: forced) { (loadedData, error) -> () in
            
            // Update data if not empty
            if let loadedData = loadedData {
                self.data = loadedData
            }
            
            // Check if should update cache
            if forced || self.shouldUpdateCacheClosure?(loadedData: self.data) ?? true {
                
                // Update delegates if did load data from cache before
                if let _ = loadedData {
                    self.delegates.performEach({ $0.loadActionUpdated(self) })
                }
                
                // Load data from main
                self.loadMain(forced: forced) { (loadedData, error) -> () in
                    completition?(loadedData: self.data, error: self.error)
                }
                
            } else {
                completition?(loadedData: self.data, error: self.error)
                
            }
            
        }
        
    }
    
    /**
    Loads new data from cache and updates the action
    
    - parameter completition: Closure called when operation finished
    */
    private func loadCache(forced forced: Bool, completition: LoadedDataErrorType?) {
        if let loadCacheClosure = loadCacheClosure {
            print(owner: "LoadAction", items: "Cache Load", level: .Info)
            loadCacheClosure(forced: forced) { (loadedData, error) -> () in
                if let error = error {
                    print(owner: "LoadAction", items: "Cache Loaded = Error \(error)", level: .Error)
                    completition?(loadedData: nil, error: error)
                } else {
                    let loadedSomething = (loadedData != nil ? "Found" : "Empty")
                    print(owner: "LoadAction", items: "Cache Loaded = Data \(loadedSomething)", level: .Info)
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
    private func loadMain(forced forced: Bool, completition: LoadedDataErrorType?) {
        print(owner: "LoadAction", items: "Main Load", level: .Info)
        loadMainClosure(forced: forced) { (loadedData, error) -> () in
            if let error = error {
                print(owner: "LoadAction", items: "Main Loaded = Error \(error)", level: .Error)
                completition?(loadedData: nil, error: error)
            } else {
                let loadedSomething = (loadedData != nil ? "Found" : "Empty")
                print(owner: "LoadAction", items: "Main Loaded = Data \(loadedSomething)", level: .Info)
                completition?(loadedData: loadedData, error: nil)
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
        limitOnce:         Bool = false,
        shouldUpdateCache: LoadedDataReturnType? = nil,
        loadCache:         LoadedResultType? = nil,
        load:              LoadedResultType,
        delegates:        [LoadActionDelegate] = [],
        dummy:             (() -> ())? = nil)
    {
        super.init(
            limitOnce: limitOnce,
            load: { (forced, result) -> Void in
            },
            delegates: delegates
        )
        loadClosure = { (forced, result) -> Void in
            self.loadInner(forced: forced, completition: result)
        }
    }
    
}

