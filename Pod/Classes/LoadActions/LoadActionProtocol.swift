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
    case Ready, Loading
}

public enum LoadActionProperties {
    case Status, Error, Value, Date
}

public protocol LoadActionDelegate: AnyObject {
    func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updatedProperties: Set<LoadActionProperties>)
}

public protocol LoadActionLoadableType: AnyObject {
    
    var status:   LoadingStatus { get }
    var error:    ErrorType?    { get }
    var date:     NSDate?       { get }
    var valueAny: Any?          { get }
    
    var delegates: [LoadActionDelegate] { get set }
    
    func loadNew()
    func loadAny(completion completion: ((result: Result<Any>) -> Void)?)
    
    var updatedProperties: Set<LoadActionProperties> { get set }
    
    func addDelegate(delegate: LoadActionDelegate)
    func removeDelegate(delegate: LoadActionDelegate)
    func sendDelegateUpdates(forced: Bool)

}

public protocol LoadActionType: LoadActionLoadableType {
    
    associatedtype T
    
    associatedtype LoadedResultType    = Result<T>
    associatedtype LoadedResultClosure = (result: LoadedResultType) -> Void
    associatedtype LoadedResult        = (completion: LoadedResultClosure?) -> Void
    
    var value: T? { get }
    
    func load(completion completion: LoadedResultClosure?)
    
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
    
    public func addDelegate(delegate: LoadActionDelegate) {
        if !delegates.contains({ $0 === delegate }) {
            delegates.append(delegate)
            delegate.loadActionUpdated(loadAction: self, updatedProperties: [])
        }
    }
    
    public func removeDelegate(delegate: LoadActionDelegate) {
        if let index = delegates.indexOf({ $0 === delegate }) {
            delegates.removeAtIndex(index)
        }
    }
    
}


