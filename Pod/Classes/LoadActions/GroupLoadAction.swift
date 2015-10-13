//
//  GroupLoadAction.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 9/17/15.
//  Copyright (c) 2014 StartApps. All rights reserved.
//  Version: 1.0
//

import AVFoundation

public enum GroupLoadOrder {
    case Parallel, Sequential, SequentialForced
}

public class GroupLoadAction<U, R>: LoadAction<U> {
    
    public typealias LoadedActionsResultType = (actions: [LoadAction<R>], result: LoadedDataErrorType) -> Void
    
    public var order:    GroupLoadOrder
    public var actions: [LoadAction<R>]
    public var actionUpdatedClosure: LoadedActionsResultType?
    
    private var actionsToLoad: [LoadAction<R>] = []
    
    /**
    Loads data giving the option of paging or loading new.
    
    - parameter forced: If true forces main load
    - parameter completition: Closure called when operation finished
    */
    private func loadInner(forced forced: Bool, completition: LoadedDataErrorType?) {
        
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
    private func loadSequential(forced forced: Bool, completition: LoadedDataErrorType?) {
        if let actionToLoad = actionsToLoad.first {
            actionsToLoad.removeAtIndex(0)
            actionToLoad.load(forced: forced) { (loadedData, error) -> Void in
                self.loadActionUpdated(loadAction: actionToLoad, completition: { (loadedData, error) -> Void in
                    if error == nil || self.order != .SequentialForced {
                        if self.actionsToLoad.count > 0 { self.sendDelegateUpdates() }
                        self.loadSequential(forced: forced, completition: completition)
                    } else {
                        self.actionsToLoad = []
                        completition?(loadedData: self.data, error: self.error)
                    }
                })
            }
        } else {
            completition?(loadedData: self.data, error: self.error)
        }
    }
    
    /**
    Loads data giving the option of paging or loading new.
    
    - parameter forced: If true forces main load
    - parameter completition: Closure called when operation finished
    */
    private func loadParallel(forced forced: Bool, completition: LoadedDataErrorType?) {
        for actionToLoad in actionsToLoad {
            actionsToLoad.removeAtIndex(0)
            actionToLoad.load(forced: forced) { (loadedData, error) -> Void in
                self.loadActionUpdated(loadAction: actionToLoad, completition: { (loadedData, error) -> Void in
                    if self.actions.find({ $0.status != .Ready }) == nil {
                        completition?(loadedData: self.data, error: self.error)
                    } else {
                        self.sendDelegateUpdates()
                    }
                })
            }
        }
    }
    
    /**
    Loads data giving the option of paging or loading new.
    
    - parameter forced: If true forces main load
    - parameter completition: Closure called when operation finished
    */
    
    private func loadActionUpdated(loadAction loadAction: LoadAction<R>, completition: LoadedDataErrorType?) {
        
        // Get error
        error = actions.find({ $0.error != nil })?.error
        
        // Get data
        if let actionUpdatedClosure = actionUpdatedClosure {
            actionUpdatedClosure(actions: actions, result: { (loadedData, error) -> Void in
                self.data  = loadedData
                if let error = error {
                    self.error = error
                }
                completition?(loadedData: self.data, error: self.error)
            })
        } else {
            //Todo, create auto appending to generic array
            data = actions.reverse().find({ $0.data as? T != nil })?.data as? T
            completition?(loadedData: self.data, error: self.error)
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
        limitOnce:         Bool = false,
        order:             GroupLoadOrder = .Parallel,
        actions:          [LoadAction<R>],
        actionUpdated:     LoadedActionsResultType? = nil,
        delegates:        [LoadActionDelegate] = [],
        dummy:             (() -> ())? = nil)
    {
        self.order = order
        self.actions = actions
        self.actionUpdatedClosure = actionUpdated
        super.init(
            limitOnce: limitOnce,
            load: { (forced, result) -> Void in
            },
            delegates: delegates
        )
        loadClosure = { (forced, result) -> Void in
            self.loadInner(forced: forced, completition: result)
        }
    }
    
}
