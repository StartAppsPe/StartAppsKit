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

public protocol LoadActionDelegate {
    
    func loadActionUpdated<L: LoadActionType>(loadAction: L)
}

public protocol LoadActionType {
    
    typealias T
    
    typealias LoadedDataReturnType = (loadedData: T?) -> Bool
    typealias LoadedResultType     = (result: LoadedDataErrorType) -> Void
    typealias LoadedDataErrorType  = (loadedData: T?, error: ErrorType?) -> Void
    
    var status: LoadingStatus { get }
    var error:  ErrorType?    { get }
    var data:   T?            { get }
    var loadedDate: NSDate?   { get }
    
    var limitOnce:                Bool                  { get }
    var shouldUpdateCacheClosure: LoadedDataReturnType? { get }
    var loadCacheClosure:         LoadedResultType?     { get }
    var loadMainClosure:          LoadedResultType!     { get }
    
    var delegates: [LoadActionDelegate] { get set }
    
    func loadNew()
    func load(forced forced: Bool, completition: LoadedDataErrorType?)
    
}

public extension LoadActionType {
    
    public mutating func addDelegate(delegate: LoadActionDelegate) {
        delegates.append(delegate)
    }
    
}