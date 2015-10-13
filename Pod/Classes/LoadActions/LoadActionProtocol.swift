//
//  LoadActionProtocol.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 9/17/15.
//  Copyright (c) 2014 StartApps. All rights reserved.
//  Version: 1.0
//

import Foundation

public enum LoadActionValues {
    case Status, Error, Data, Date
}

public enum LoadingStatus {
    case Ready, Loading, Paging
}

public protocol LoadActionDelegate: AnyObject {
    func loadActionUpdated<L: LoadActionType>(loadAction: L, updatedValues: [LoadActionValues])
}

public protocol LoadActionType: AnyObject {
    
    typealias T
    
    typealias LoadedDataReturnType = (loadedData: T?) -> Bool
    typealias LoadedDataErrorType  = (loadedData: T?, error: ErrorType?) -> Void
    typealias LoadedResultType     = (forced: Bool, result: LoadedDataErrorType) -> Void
    
    var status: LoadingStatus { get }
    var error:  ErrorType?    { get }
    var data:   T?            { get }
    var date:   NSDate?       { get }
    
    var delegates: [LoadActionDelegate] { get set }
    
    func loadNew()
    func load(forced forced: Bool, completition: LoadedDataErrorType?)
    
    var updatedValues: [LoadActionValues] { get set }
}

public extension LoadActionType {
    
    /**
    Loads new data forced replacing the previous stored data
    */
    public func loadNew() {
        load(forced: true, completition: nil)
    }
    
}

public extension LoadActionType {
    
    public func addDelegate(delegate: LoadActionDelegate) {
        if delegates.indexOf({ $0 === delegate }) == nil {
            delegates.append(delegate)
        }
    }
    
    public func removeDelegate(delegate: LoadActionDelegate) {
        if let index = delegates.indexOf({ $0 === delegate }) {
            delegates.removeAtIndex(index)
        }
    }
    
    public func sendDelegateUpdates() {
        guard updatedValues.count > 0 else { return }
        delegates.performEach({ $0.loadActionUpdated(self, updatedValues: self.updatedValues) })
        updatedValues = []
    }
    
}