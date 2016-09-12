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
    NSNotificationCenter.defaultCenter().postNotificationName(LoadActionUpdatedNotification, object: nil)
}
}
public var LoadActionAllStatus: LoadingStatus {
    return (LoadActionLoadingCount == 0 ? .Ready : .Loading)
}

public class LoadAction<T>: LoadActionType {
    
    public typealias LoadResultType     = Result<T>
    public typealias LoadResultClosure  = (result: LoadResultType) -> Void
    public typealias LoadResult         = (completion: LoadResultClosure) -> Void
    
    public var updatedProperties: Set<LoadActionProperties> = []
    public var delegates: [LoadActionDelegate] = []
    
    public var status: LoadingStatus = .Ready {
        didSet { updatedProperties.insert(.Status) }
    }
    public var error: ErrorType? {
        didSet { updatedProperties.insert(.Error) }
    }
    public var value: T? {
        didSet { updatedProperties.insert(.Value); date = NSDate.now() }
    }
    public var date: NSDate? {
        didSet { updatedProperties.insert(.Date) }
    }
    
    public var loadClosure: LoadResult!
    
    public func loadNew() {
        load(completion: nil)
    }
    
    /**
     Loads value giving the option of paging or loading new.
     
     - parameter completion: Closure called when operation finished
     */
    public func load(completion completion: LoadResultClosure?) {
        LoadActionLoadingCount += 1
        print(owner: "LoadAction[Main]", items: "Load Began", level: .Verbose)
        
        // Adjust loading status to loading kind
        status = .Loading
        sendDelegateUpdates()
        
        // Load value
        loadClosure() { (result) -> () in
            
            switch result {
            case .Failure(let error):
                print(owner: "LoadAction[Main]", items: "Loaded Failure (\(error))", level: .Error)
                self.error = error
            case .Success(let loadedValue):
                print(owner: "LoadAction[Main]", items: "Loaded Success", level: .Verbose)
                self.value = loadedValue
            }
            
            // Adjust loading status to loaded kind and call completion
            self.status = .Ready
            LoadActionLoadingCount -= 1
            self.sendDelegateUpdates()
            completion?(result: result)
        }
        
    }
    
    public func loadAny(completion completion: ((result: Result<Any>) -> Void)?) {
        load() { (resultGeneric) -> Void in
            switch resultGeneric {
            case .Success(let loadedValue):
                completion?(result: .Success(loadedValue))
            case .Failure(let error):
                completion?(result: .Failure(error))
            }
        }
    }
    
    /**
     Quick initializer with all closures
     
     - parameter load: Closure to load from web, must call result closure when finished
     - parameter delegates: Array containing objects that react to updated value
     */
    public init(
        load:  LoadResult,
        dummy: (() -> ())? = nil)
    {
        self.loadClosure = load
    }
    
}

public func Load<B>(@noescape startLoadAction: (() -> LoadAction<B>)) -> LoadAction<B> {
    return startLoadAction()
}

public extension LoadAction {
    
    public func then<B>(@noescape thenLoadAction: ((loadAction: LoadAction<T>) -> LoadAction<B>)) -> LoadAction<B> {
        return thenLoadAction(loadAction: self)
    }
    
}
