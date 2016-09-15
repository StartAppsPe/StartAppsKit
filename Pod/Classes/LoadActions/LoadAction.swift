//
//  LoadAction.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 9/17/15.
//  Copyright (c) 2014 StartApps. All rights reserved.
//  Version: 1.0
//

import Foundation

public let LoadActionUpdatedNotification = "LoadActionUpdatedNotification"
public var LoadActionLoadingCount: Int = 0 {
didSet {
    NotificationCenter.default.post(name: Notification.Name(rawValue: LoadActionUpdatedNotification), object: nil)
}
}
public var LoadActionAllStatus: LoadingStatus {
    return (LoadActionLoadingCount == 0 ? .ready : .loading)
}

open class LoadAction<T>: LoadActionType {
    
    public typealias LoadResultClosure  = (_ result: Result<T>) -> Void
    public typealias LoadResult         = (_ completion: @escaping LoadResultClosure) -> Void
    
    open var updatedProperties: Set<LoadActionProperties> = []
    open var delegates: [LoadActionDelegate] = []
    
    open var status: LoadingStatus = .ready {
        didSet { updatedProperties.insert(.status) }
    }
    open var error: Error? {
        didSet { updatedProperties.insert(.error) }
    }
    open var value: T? {
        didSet { updatedProperties.insert(.value); date = Date.now() }
    }
    open var date: Date? {
        didSet { updatedProperties.insert(.date) }
    }
    
    open var loadClosure: LoadResult!
    
    open func loadNew() {
        load(completion: nil)
    }
    
    /**
     Loads value giving the option of paging or loading new.
     
     - parameter completion: Closure called when operation finished
     */
    open func load(completion: LoadResultClosure?) {
        LoadActionLoadingCount += 1
        print(owner: "LoadAction[Main]", items: "Load Began", level: .verbose)
        
        // Adjust loading status to loading kind
        status = .loading
        sendDelegateUpdates()
        
        // Load value
        loadClosure() { (result) -> () in
            
            switch result {
            case .failure(let error):
                print(owner: "LoadAction[Main]", items: "Loaded Failure (\(error))", level: .error)
                self.error = error
            case .success(let loadedValue):
                print(owner: "LoadAction[Main]", items: "Loaded Success", level: .verbose)
                self.value = loadedValue
            }
            
            // Adjust loading status to loaded kind and call completion
            self.status = .ready
            LoadActionLoadingCount -= 1
            self.sendDelegateUpdates()
            completion?(result)
        }
        
    }
    
    open func loadAny(completion: ((_ result: Result<Any>) -> Void)?) {
        load() { (resultGeneric) -> Void in
            switch resultGeneric {
            case .success(let loadedValue):
                completion?(.success(loadedValue))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    /**
     Quick initializer with all closures
     
     - parameter load: Closure to load from web, must call result closure when finished
     - parameter delegates: Array containing objects that react to updated value
     */
    public init(
        load:  @escaping LoadResult,
        dummy: (() -> ())? = nil)
    {
        self.loadClosure = load
    }
    
}

public func Load<B>(_ startLoadAction: (() -> LoadAction<B>)) -> LoadAction<B> {
    return startLoadAction()
}

public extension LoadAction {
    
    public func then<B>(_ thenLoadAction: ((_ loadAction: LoadAction<T>) -> LoadAction<B>)) -> LoadAction<B> {
        return thenLoadAction(self)
    }
    
}
