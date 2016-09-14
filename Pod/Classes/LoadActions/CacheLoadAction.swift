//
//  CacheLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 9/21/15.
//
//

import Foundation

open class CacheLoadAction<T>: LoadAction<T> {
    
    public typealias UpdateCacheResult = (_ loadAction: CacheLoadAction<T>) throws -> Bool
    public typealias SaveToCacheResult = (_ loadedValue: T, _ loadAction: CacheLoadAction<T>) throws -> Void
    
    open var cacheLoadAction:    LoadAction<T>
    open var baseLoadAction:     LoadAction<T>
    open var saveToCacheClosure: SaveToCacheResult?
    open var updateCacheClosure: UpdateCacheResult
    
    fileprivate var useForcedNext: Bool = false
    
    
    /**
     Loads value giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completion: Closure called when operation finished
     */
    open func load(forced: Bool, completion: LoadResultClosure?) {
        useForcedNext = forced
        load(completion: completion)
    }
    
    open override func loadNew() {
        load(forced: true, completion: nil)
    }
    
    fileprivate func loadInner(completion: @escaping LoadResultClosure) {
        guard useForcedNext == false else {
            self.loadCache(completion: { (result) in
                self.loadBase(completion: completion)
            })
            useForcedNext = false
            return
        }
        self.loadCache(completion: { (result) in
            do {
                if try self.updateCacheClosure(self) {
                    self.loadBase(completion: completion)
                } else {
                    completion(result)
                }
            } catch(let error) {
                completion(.failure(error))
            }
        })
    }
    
    /**
     Loads new data from cache and updates the action
     
     - parameter completion: Closure called when operation finished
     */
    fileprivate func loadCache(completion: @escaping LoadResultClosure) {
        print(owner: "LoadAction[Cache]", items: "Cache Load Began", level: .info)
        cacheLoadAction.load { (result) in
            switch result {
            case .success(_):
                print(owner: "LoadAction[Cache]", items: "Cache Load Success", level: .info)
                completion(result)
            case .failure(let error):
                print(owner: "LoadAction[Cache]", items: "Cache Load Failure. \(error)", level: .error)
                completion(result)
            }
        }
    }
    
    /**
     Loads new data from base and updates the action
     
     - parameter completion: Closure called when operation finished
     */
    fileprivate func loadBase(completion: @escaping LoadResultClosure) {
        print(owner: "LoadAction[Cache]", items: "Base Load Began", level: .info)
        baseLoadAction.load { (result) in
            switch result {
            case .success(let value):
                if let saveToCacheClosure = self.saveToCacheClosure {
                    print(owner: "LoadAction[Cache]", items: "Save to Cache Began", level: .info)
                    do {
                        try saveToCacheClosure(value, self)
                        print(owner: "LoadAction[Cache]", items: "Save to Cache Success", level: .info)
                        print(owner: "LoadAction[Cache]", items: "Base Load Success", level: .info)
                        completion(result)
                    } catch(let error) {
                        print(owner: "LoadAction[Cache]", items: "Save to Cache Failure. \(error)", level: .error)
                        print(owner: "LoadAction[Cache]", items: "Base Load Failure. \(error)", level: .error)
                        completion(.failure(error))
                    }
                } else {
                    print(owner: "LoadAction[Cache]", items: "Base Load Success", level: .info)
                    completion(result)
                }
            case .failure(let error):
                print(owner: "LoadAction[Cache]", items: "Base Load Failure. \(error)", level: .error)
                completion(result)
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
        updateCache:     @escaping UpdateCacheResult,
        dummy:           (() -> ())? = nil)
    {
        self.baseLoadAction     = baseLoadAction
        self.cacheLoadAction    = cacheLoadAction
        self.saveToCacheClosure = saveToCache
        self.updateCacheClosure = updateCache
        super.init(
            load: { _ in }
        )
        loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
    }
    
}

