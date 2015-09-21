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
    case Ready, Loading, Paging
}

public protocol LoadActionDelegate: AnyObject {
    func loadActionUpdated<L: LoadActionType>(loadAction: L)
}

public protocol LoadActionType: AnyObject {
    
    typealias T
    
    typealias LoadedDataReturnType = (loadedData: T?) -> Bool
    typealias LoadedResultType     = (forced: Bool, result: LoadedDataErrorType) -> Void
    typealias LoadedDataErrorType  = (loadedData: T?, error: ErrorType?) -> Void
    
    var status: LoadingStatus { get }
    var error:  ErrorType?    { get }
    var data:   T?            { get }
    var loadedDate: NSDate?   { get }
    
    var delegates: [LoadActionDelegate] { get set }
    
    func loadNew()
    func load(forced forced: Bool, completition: LoadedDataErrorType?)
    
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
    
}