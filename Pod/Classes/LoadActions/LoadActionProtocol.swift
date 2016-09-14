//
//  LoadActionProtocol.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 9/17/15.
//  Copyright (c) 2014 StartApps. All rights reserved.
//  Version: 1.0
//

import Foundation

public enum LoadingStatus {
    case ready, loading
}

public enum LoadActionProperties {
    case status, error, value, date
}

public protocol LoadActionDelegate: AnyObject {
    func loadActionUpdated<L: LoadActionType>(loadAction: L, updatedProperties: Set<LoadActionProperties>)
}

public protocol LoadActionLoadableType: AnyObject {
    
    var status:   LoadingStatus { get }
    var error:    Error?        { get }
    var date:     Date?         { get }
    var valueAny: Any?          { get }
    
    var delegates: [LoadActionDelegate] { get set }
    
    func loadNew()
    func loadAny(completion: ((_ result: Result<Any>) -> Void)?)
    
    var updatedProperties: Set<LoadActionProperties> { get set }
    
    func addDelegate(_ delegate: LoadActionDelegate)
    func removeDelegate(_ delegate: LoadActionDelegate)
    func sendDelegateUpdates(forced: Bool)

}

public protocol LoadActionType: LoadActionLoadableType {
    
    associatedtype T
    
    associatedtype LoadedResultType    = Result<T>
    associatedtype LoadedResultClosure = (_ result: LoadedResultType) -> Void
    associatedtype LoadedResult        = (_ completion: LoadedResultClosure?) -> Void
    
    var value: T? { get }
    
    func load(completion: LoadedResultClosure?)
    
}

public extension LoadActionType {
    
    public var valueAny: Any? {
        return value
    }
    
    public func sendDelegateUpdates(forced: Bool = false) {
        guard forced || updatedProperties.count > 0 else { return }
        delegates.performEach({ $0.loadActionUpdated(loadAction: self, updatedProperties: self.updatedProperties) })
        updatedProperties = []
    }
    
    public func addDelegate(_ delegate: LoadActionDelegate) {
        if !delegates.contains(where: { $0 === delegate }) {
            delegates.append(delegate)
            delegate.loadActionUpdated(loadAction: self, updatedProperties: [])
        }
    }
    
    public func removeDelegate(_ delegate: LoadActionDelegate) {
        if let index = delegates.index(where: { $0 === delegate }) {
            delegates.remove(at: index)
        }
    }
    
}


