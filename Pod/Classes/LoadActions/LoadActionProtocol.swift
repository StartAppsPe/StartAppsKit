//
//  LoadActionProtocol.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 9/17/15.
//  Copyright (c) 2014 StartApps. All rights reserved.
//  Version: 1.0
//

import Foundation

public enum Result<T, E> {
    case Success(T?), Failure(E)
    var succeeded: Bool {
        switch self {
        case .Success(_): return true
        case .Failure(_): return false
        }
    }
    var data: T? {
        switch self {
        case .Success(let data): return data
        case .Failure(_): return nil
        }
    }
    var error: E? {
        switch self {
        case .Success(_): return nil
        case .Failure(let error): return error
        }
    }
}

public enum LoadingStatus {
    case Ready, Loading, Paging
}

public enum LoadActionValues {
    case Status, Error, Data, Date
}

public protocol LoadActionDelegate: AnyObject {
    func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updatedValues: Set<LoadActionValues>)
}

public protocol LoadActionLoadableType: AnyObject {
    
    var status:  LoadingStatus { get }
    var error:   ErrorType?    { get }
    var date:    NSDate?       { get }
    var dataAny: Any?          { get }
    
    var delegates: [LoadActionDelegate] { get set }
    
    func loadNew()
    func loadAny(forced forced: Bool, completition: ((result: Result<Any, ErrorType>) -> Void)?)
    
    var updatedValues: Set<LoadActionValues> { get set }
    
    func addDelegate(delegate: LoadActionDelegate)
    func removeDelegate(delegate: LoadActionDelegate)
    func sendDelegateUpdates(forced: Bool)

}

public protocol LoadActionType: LoadActionLoadableType {
    
    typealias T
    
    typealias ResultType     = Result<T, ErrorType>
    typealias ResultClosure  = (result: ResultType) -> Void
    typealias LoadedResult   = (forced: Bool, completition: ResultClosure?) -> Void
    
    var data: T? { get }
    
    func load(forced forced: Bool, completition: ResultClosure?)
    
}

public extension LoadActionType {
    
    /**
     Loads new data forced replacing the previous stored data
     */
    public func loadNew() {
        load(forced: true, completition: nil)
    }
    
    var dataAny: Any? {
        return data
    }
    
    public func sendDelegateUpdates(forced: Bool = false) {
        guard forced || updatedValues.count > 0 else { return }
        delegates.performEach({ $0.loadActionUpdated(loadAction: self, updatedValues: self.updatedValues) })
        updatedValues = []
    }
    
    public func addDelegate(delegate: LoadActionDelegate) {
        if !delegates.contains({ $0 === delegate }) {
            delegates.append(delegate)
            delegate.loadActionUpdated(loadAction: self, updatedValues: [])
        }
    }
    
    public func removeDelegate(delegate: LoadActionDelegate) {
        if let index = delegates.indexOf({ $0 === delegate }) {
            delegates.removeAtIndex(index)
        }
    }
    
}


