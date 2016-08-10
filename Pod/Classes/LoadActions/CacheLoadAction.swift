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
    
    public typealias SaveToCacheResultType    = Result<Bool, ErrorType>
    public typealias SaveToCacheResultClosure = (result: SaveToCacheResultType) -> Void
    public typealias SaveToCacheResult        = (loadedValue: T, loadAction: CacheLoadAction<T>, completion: SaveToCacheResultClosure) -> Void
    
    public var cacheLoadAction:    LoadAction<T>
    public var baseLoadAction:     LoadAction<T>
    public var saveToCacheClosure: SaveToCacheResult?
    public var useCacheClosure:    UseCacheResult
    
    private var useForcedNext: Bool = false
    
    
    /**
     Loads value giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completion: Closure called when operation finished
     */
    public func load(forced forced: Bool, completion: LoadResultClosure?) {
        useForcedNext = forced
        super.load(completion: completion)
    }
    
    public func loadNew() {
        load(forced: true, completion: nil)
    }
    
    private func loadInner(completion completion: LoadResultClosure) {
        guard useForcedNext == false else {
            loadBase(completion: completion)
            useForcedNext = false
            return
        }
        useCacheClosure(loadAction: self) { (useCacheResult) in
            switch useCacheResult {
            case .Failure(let error):
                completion(result: Result.Failure(error))
            case .Success(let useCache):
                if useCache {
                    self.loadCache(completion: completion)
                } else {
                    self.loadBase(completion: completion)
                }
            }
        }
        
    }
    
    /**
    Loads new data from cache and updates the action
    
    - parameter completion: Closure called when operation finished
    */
    private func loadCache(completion completion: LoadResultClosure) {
        print(owner: "LoadAction[Cache]", items: "Cache Load", level: .Info)
        cacheLoadAction.load(completion: completion)
    }
    
    /**
    Loads new data from base and updates the action
    
    - parameter completion: Closure called when operation finished
    */
    private func loadBase(completion completion: LoadResultClosure) {
        print(owner: "LoadAction[Cache]", items: "Base Load", level: .Info)
        baseLoadAction.load { (result) in
            switch result {
            case .Success(let value):
                if let saveToCacheClosure = self.saveToCacheClosure {
                    saveToCacheClosure(loadedValue: value, loadAction: self, completion: { (saveToCacheResult) in
                        completion(result: result)
                    })
                } else {
                    completion(result: result)
                }
            case .Failure(_):
                completion(result: result)
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
        baseLoadAction:  LoadAction<T>,
        cacheLoadAction: LoadAction<T>,
        saveToCache:     SaveToCacheResult?,
        useCache:        UseCacheResult,
        delegates:       [LoadActionDelegate] = [],
        dummy:           (() -> ())? = nil)
    {
        self.baseLoadAction     = baseLoadAction
        self.cacheLoadAction    = cacheLoadAction
        self.saveToCacheClosure = saveToCache
        self.useCacheClosure    = useCache
        super.init(
            load:      { _ in },
            delegates: delegates
        )
        loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
    }
    
}

