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

public enum IgnoreValue { }

public class GroupLoadAction<T>: LoadAction<T> {
    
    public typealias LoadedResultType    = Result<T, ErrorType>
    public typealias LoadedResultClosure = (result: LoadedResultType) -> Void
    public typealias LoadedResult        = (completion: LoadedResultClosure) -> Void
    
    public typealias ProcessValue  = (actions: [LoadActionLoadableType]) -> T?
    public typealias ProcessError  = (actions: [LoadActionLoadableType]) -> ErrorType?

    public var processValueClosure: ProcessValue?
    public var processErrorClosure: ProcessError?
    
    public  var order:          GroupLoadOrder
    public  var actions:       [LoadActionLoadableType]
    private var actionsToLoad: [LoadActionLoadableType] = []
    
    /**
     Loads data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completion: Closure called when operation finished
     */
    private func loadInner(completion completion: LoadedResultClosure) {
        
        // Copy load actions
        actionsToLoad = actions
        
        // choose loading function
        switch order {
        case .Sequential, .SequentialForced:
            loadSequential(completion: completion)
        case .Parallel:
            loadParallel(completion: completion)
        }
        
    }
    
    /**
     Loads data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completion: Closure called when operation finished
     */
    private func loadSequential(completion completion: LoadedResultClosure) {
        if let actionToLoad = actionsToLoad.popFirst() {
            actionToLoad.loadAny() { (result) -> Void in
                if result.isSuccess || self.order != .SequentialForced {
                    if self.actionsToLoad.count > 0 { self.sendDelegateUpdates() }
                    self.loadSequential(completion: completion)
                } else {
                    self.actionsToLoad = []
                    completion(result: Result.Failure(self.error!))
                }
            }
        } else {
            completion(result: Result.Success(self.value!))
        }
    }
    
    /**
     Loads data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completion: Closure called when operation finished
     */
    private func loadParallel(completion completion: LoadedResultClosure) {
        while let actionToLoad = actionsToLoad.popFirst() {
            actionToLoad.loadAny() { (result) -> Void in
                if self.actions.find({ $0.status != .Ready }) == nil {
                    if let error = self.error { // self.actions.find({ $0.error != nil }) == nil
                        completion(result: Result.Failure(error))
                    } else {
                        completion(result: Result.Success(self.value!))
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
     - parameter completion: Closure called when operation finished
     */
    
    func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updated: Set<LoadActionProperties>) {
        
        // Get error
        if let processErrorClosure = processErrorClosure {
            error = processErrorClosure(actions: actions)
        } else {
            error = GroupLoadAction.DefaultProcessErrorFirst(actions: actions)
        }
        
        // Get value
        if let processValueClosure = processValueClosure {
            value = processValueClosure(actions: actions)
        } else if value is IgnoreValue {
            value = GroupLoadAction.DefaultProcessValueIgnore(actions: actions)
        } else {
            value = GroupLoadAction.DefaultProcessValueLast(actions: actions)
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
        processValue:      ProcessValue? = nil,
        processError:      ProcessError? = nil,
        delegates:        [LoadActionDelegate] = [],
        dummy:             (() -> ())? = nil)
    {
        self.order = order
        self.actions = actions
        self.processValueClosure = processValue
        self.processErrorClosure = processError
        super.init(
            load: { (result) -> Void in
            },
            delegates: delegates
        )
        loadClosure = { (result) -> Void in
            self.loadInner(completion: result)
        }
    }
    
    class var DefaultProcessErrorFirst: ProcessError {
        return { (actions: [LoadActionLoadableType]) -> ErrorType? in
            return actions.find({ $0.error != nil })?.error
        }
    }
    
    class var DefaultProcessValueLast: ProcessValue {
        return { (actions: [LoadActionLoadableType]) -> T? in
            return actions.reverse().find({ $0.valueAny as? T != nil })?.valueAny as? T
        }
    }
    
    class var DefaultProcessValueIgnore: ProcessValue {
        return { (actions: [LoadActionLoadableType]) -> T? in
            return nil
        }
    }
    
}
