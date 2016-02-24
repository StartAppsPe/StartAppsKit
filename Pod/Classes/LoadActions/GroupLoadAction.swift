//
//  GroupLoadAction.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 9/17/15.
//  Copyright (c) 2014 StartApps. All rights reserved.
//  Version: 1.0
//

import Foundation

public enum GroupLoadOrder {
    case Parallel, Sequential, SequentialForced
}

public class GroupLoadAction<T>: LoadAction<T> {
    
    public typealias ResultType    = Result<T, ErrorType>
    public typealias ResultClosure = (result: ResultType) -> Void
    public typealias LoadedResult  = (forced: Bool, completition: ResultClosure) -> Void
    
    public typealias ProcessData   = (actions: [LoadActionLoadableType]) -> T?
    public typealias ProcessError  = (actions: [LoadActionLoadableType]) -> ErrorType?

    public var processDataClosure:   ProcessData?
    public var processErrorClosure:  ProcessError?
    
    public  var order:          GroupLoadOrder
    public  var actions:       [LoadActionLoadableType]
    private var actionsToLoad: [LoadActionLoadableType] = []
    
    /**
     Loads data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completition: Closure called when operation finished
     */
    private func loadInner(forced forced: Bool, completition: ResultClosure?) {
        
        // Copy load actions
        actionsToLoad = actions
        
        // choose loading function
        switch order {
        case .Sequential, .SequentialForced:
            loadSequential(forced: forced, completition: completition)
        case .Parallel:
            loadParallel(forced: forced, completition: completition)
        }
        
    }
    
    /**
     Loads data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completition: Closure called when operation finished
     */
    private func loadSequential(forced forced: Bool, completition: ResultClosure?) {
        if let actionToLoad = actionsToLoad.first {
            actionsToLoad.removeAtIndex(0)
            actionToLoad.loadAny(forced: forced) { (result) -> Void in
                if result.succeeded || self.order != .SequentialForced {
                    if self.actionsToLoad.count > 0 { self.sendDelegateUpdates() }
                    self.loadSequential(forced: forced, completition: completition)
                } else {
                    self.actionsToLoad = []
                    completition?(result: Result.Failure(self.error!))
                }
            }
        } else {
            completition?(result: .Success(self.data))
        }
    }
    
    /**
     Loads data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completition: Closure called when operation finished
     */
    private func loadParallel(forced forced: Bool, completition: ResultClosure?) {
        for actionToLoad in actionsToLoad {
            actionsToLoad.removeAtIndex(0)
            actionToLoad.loadAny(forced: forced) { (result) -> Void in
                if self.actions.find({ $0.status != .Ready }) == nil {
                    if self.actions.find({ $0.error != nil }) == nil {
                        completition?(result: Result.Failure(self.error!))
                    } else {
                        completition?(result: Result.Success(self.data))
                    }
                } else {
                    self.sendDelegateUpdates()
                }
            }
        }
    }
    
    /**
     Loads data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completition: Closure called when operation finished
     */
    
    func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updatedValues: [LoadActionValues]) {
        
        // Get error
        if let processErrorClosure = processErrorClosure {
            error = processErrorClosure(actions: actions)
        } else {
            error = GroupLoadAction.DefaultProcessErrorFirst(actions: actions)
        }
        
        // Get data
        if let processDataClosure = processDataClosure {
            data = processDataClosure(actions: actions)
        } else {
            data = GroupLoadAction.DefaultProcessDataLast(actions: actions)
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
        order:             GroupLoadOrder = .Parallel,
        actions:          [LoadActionLoadableType],
        processData:       ProcessData? = nil,
        processError:      ProcessError? = nil,
        delegates:        [LoadActionDelegate] = [],
        dummy:             (() -> ())? = nil)
    {
        self.order = order
        self.actions = actions
        self.processDataClosure = processData
        self.processErrorClosure = processError
        super.init(
            load: { (forced, result) -> Void in
            },
            delegates: delegates
        )
        loadClosure = { (forced, result) -> Void in
            self.loadInner(forced: forced, completition: result)
        }
    }
    
    class var DefaultProcessErrorFirst: ProcessError {
        return { (actions: [LoadActionLoadableType]) -> ErrorType? in
            return actions.find({ $0.error != nil })?.error
        }
    }
    
    class var DefaultProcessDataLast: ProcessData {
        return { (actions: [LoadActionLoadableType]) -> T? in
            return actions.reverse().find({ $0.dataAny as? T != nil })?.dataAny as? T
        }
    }
    
}
