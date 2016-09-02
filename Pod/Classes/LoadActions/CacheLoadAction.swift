//
//  CacheLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 9/21/15.
//
//

import Foundation

public class CacheLoadAction<T>: LoadAction<T> {
    
    public typealias UpdateCacheResultType     = Result<Bool, ErrorType>
    public typealias UpdateCacheResultClosure  = (result: UpdateCacheResultType) -> Void
    public typealias UpdateCacheResult         = (loadAction: CacheLoadAction<T>, completion: UpdateCacheResultClosure) -> Void
    
    public typealias SaveToCacheResultType    = Result<Bool, ErrorType>
    public typealias SaveToCacheResultClosure = (result: SaveToCacheResultType) -> Void
    public typealias SaveToCacheResult        = (loadedValue: T, loadAction: CacheLoadAction<T>, completion: SaveToCacheResultClosure) -> Void
    
    public var cacheLoadAction:    LoadAction<T>
    public var baseLoadAction:     LoadAction<T>
    public var saveToCacheClosure: SaveToCacheResult?
    public var updateCacheClosure: UpdateCacheResult
    
    private var useForcedNext: Bool = false
    
    
    /**
     Loads value giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completion: Closure called when operation finished
     */
    public func load(forced forced: Bool, completion: LoadResultClosure?) {
        useForcedNext = forced
        load(completion: completion)
    }
    
    public override func loadNew() {
        load(forced: true, completion: nil)
    }
    
    private func loadInner(completion completion: LoadResultClosure) {
        guard useForcedNext == false else {
            self.loadCache(completion: { (result) in
                self.loadBase(completion: completion)
            })
            useForcedNext = false
            return
        }
        updateCacheClosure(loadAction: self) { (updateCacheResult) in
            switch updateCacheResult {
            case .Success(let updateCache):
                self.loadCache(completion: { (result) in
                    if updateCache {
                        self.loadBase(completion: completion)
                    } else {
                        completion(result: result)
                    }
                })
            case .Failure(let error):
                completion(result: Result.Failure(error))
            }
        }
    }
    
    /**
    Loads new data from cache and updates the action
    
    - parameter completion: Closure called when operation finished
    */
    private func loadCache(completion completion: LoadResultClosure) {
        print(owner: "LoadAction[Cache]", items: "Cache Load Began", level: .Info)
        cacheLoadAction.load { (result) in
            switch result {
            case .Success(let value):
                print(owner: "LoadAction[Cache]", items: "Cache Load Success", level: .Info)
                completion(result: result)
            case .Failure(let error):
                print(owner: "LoadAction[Cache]", items: "Cache Load Failure. \(error)", level: .Error)
                completion(result: result)
            }
        }
    }
    
    /**
    Loads new data from base and updates the action
    
    - parameter completion: Closure called when operation finished
    */
    private func loadBase(completion completion: LoadResultClosure) {
        print(owner: "LoadAction[Cache]", items: "Base Load Began", level: .Info)
        baseLoadAction.load { (result) in
            switch result {
            case .Success(let value):
                if let saveToCacheClosure = self.saveToCacheClosure {
                    print(owner: "LoadAction[Cache]", items: "Save to Cache Began", level: .Info)
                    saveToCacheClosure(loadedValue: value, loadAction: self, completion: { (saveToCacheResult) in
                        switch saveToCacheResult {
                        case .Success(let value):
                            print(owner: "LoadAction[Cache]", items: "Save to Cache Success", level: .Info)
                            print(owner: "LoadAction[Cache]", items: "Base Load Success", level: .Info)
                            completion(result: result)
                        case .Failure(let error):
                            print(owner: "LoadAction[Cache]", items: "Save to Cache Failure. \(error)", level: .Error)
                            print(owner: "LoadAction[Cache]", items: "Base Load Failure. \(error)", level: .Error)
                            completion(result: result)
                        }
                    })
                } else {
                    print(owner: "LoadAction[Cache]", items: "Base Load Success", level: .Info)
                    completion(result: result)
                }
            case .Failure(let error):
                print(owner: "LoadAction[Cache]", items: "Base Load Failure. \(error)", level: .Error)
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
        updateCache:     UpdateCacheResult,
        delegates:       [LoadActionDelegate] = [],
        dummy:           (() -> ())? = nil)
    {
        self.baseLoadAction     = baseLoadAction
        self.cacheLoadAction    = cacheLoadAction
        self.saveToCacheClosure = saveToCache
        self.updateCacheClosure = updateCache
        super.init(
            load:      { _ in },
            delegates: delegates
        )
        loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
    }
    
}

