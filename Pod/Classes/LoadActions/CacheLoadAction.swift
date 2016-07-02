//
//  CacheLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 9/21/15.
//
//

import Foundation

public class CacheLoadAction<T>: LoadAction<T> {
    
    public typealias UseCacheResultType     = Result<Bool, ErrorType>
    public typealias UseCacheResultClosure  = (result: UseCacheResultType) -> Void
    public typealias UseCacheResult         = (loadAction: CacheLoadAction<T>, completion: UseCacheResultClosure) -> Void
    
    public var useCacheClosure: UseCacheResult
    public var cacheLoadAction: LoadAction<T>
    public var baseLoadAction:  LoadAction<T>
    
    /**
    Loads data giving the option of paging or loading new.
    
    - parameter forced: If true forces main load
    - parameter completion: Closure called when operation finished
    */
    private func loadInner(forced forced: Bool, completion: LoadResultClosure) {
        guard forced == false else {
            loadBase(forced: forced, completion: completion)
            return
        }
        useCacheClosure(loadAction: self) { (useCacheResult) in
            switch useCacheResult {
            case .Failure(let error):
                completion(result: Result.Failure(error))
            case .Success(let useCache):
                if useCache {
                    self.loadCache(forced: forced, completion: completion)
                } else {
                    self.loadBase(forced: forced, completion: completion)
                }
            }
        }
        
    }
    
    /**
    Loads new data from cache and updates the action
    
    - parameter completion: Closure called when operation finished
    */
    private func loadCache(forced forced: Bool, completion: LoadResultClosure) {
        print(owner: "LoadAction[Cache]", items: "Cache Load", level: .Info)
        cacheLoadAction.load(forced: forced, completion: completion)
    }
    
    /**
    Loads new data from base and updates the action
    
    - parameter completion: Closure called when operation finished
    */
    private func loadBase(forced forced: Bool, completion: LoadResultClosure) {
        print(owner: "LoadAction[Cache]", items: "Base Load", level: .Info)
        baseLoadAction.load(forced: forced, completion: completion)
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
        baseLoadAction:  LoadAction<T>,
        cacheLoadAction: LoadAction<T>,
        useCache:        UseCacheResult,
        delegates:       [LoadActionDelegate] = [],
        dummy:           (() -> ())? = nil)
    {
        self.baseLoadAction  = baseLoadAction
        self.cacheLoadAction = cacheLoadAction
        self.useCacheClosure = useCache
        super.init(
            load:      { _,_ in },
            delegates: delegates
        )
        loadClosure = { (forced, completion) -> Void in
            self.loadInner(forced: forced, completion: completion)
        }
    }
    
}

