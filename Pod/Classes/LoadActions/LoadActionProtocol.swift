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
    case Success(T), Failure(E)
    public var isSuccess: Bool {
        switch self {
        case .Success: return true
        case .Failure: return false
        }
    }
    public var isFailure: Bool {
        switch self {
        case .Success: return false
        case .Failure: return true
        }
    }
    public var value: T? {
        switch self {
        case .Success(let value): return value
        case .Failure(_): return nil
        }
    }
    public var error: E? {
        switch self {
        case .Success(_): return nil
        case .Failure(let error): return error
        }
    }
}

extension Result: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        switch self {
        case .Success:
            return "Result(SUCCESS)"
        case .Failure:
            return "Result(FAILURE)"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .Success(let value):
            return "Result(SUCCESS): \(value)"
        case .Failure(let error):
            return "Result(FAILURE): \(error)"
        }
    }
    
}

public enum LoadingStatus {
    case Ready, Loading, Paging
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
    func loadAny(completion completion: ((result: Result<Any, ErrorType>) -> Void)?)
    
    var updatedProperties: Set<LoadActionProperties> { get set }
    
    func addDelegate(delegate: LoadActionDelegate)
    func removeDelegate(delegate: LoadActionDelegate)
    func sendDelegateUpdates(forced: Bool)

}

public protocol LoadActionType: LoadActionLoadableType {
    
    associatedtype T
    
    associatedtype LoadedResultType    = Result<T, ErrorType>
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


