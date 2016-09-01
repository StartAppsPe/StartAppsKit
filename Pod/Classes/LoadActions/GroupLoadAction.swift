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

public struct IgnoreValue { }

public class GroupLoadAction<T>: LoadAction<T> {
    
    public typealias LoadedResultType    = Result<T, ErrorType>
    public typealias LoadedResultClosure = (result: LoadedResultType) -> Void
    public typealias LoadedResult        = (completion: LoadedResultClosure) -> Void
    
    public typealias ProcessValue  = (actions: [LoadActionLoadableType]) -> T?
    public typealias ProcessError  = (actions: [LoadActionLoadableType]) -> ErrorType?
    
    public var processValueClosure: ProcessValue
    public var processErrorClosure: ProcessError
    
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
                self.updateValueAndError()
                if result.isSuccess || self.order != .SequentialForced {
                    if self.actionsToLoad.count > 0 { self.sendDelegateUpdates() }
                    self.loadSequential(completion: completion)
                } else {
                    self.actionsToLoad = []
                    if let error = self.error {
                        completion(result: .Failure(error))
                    } else {
                        let error = NSError(domain: "LoadAction[Group]", code: 2913, description: "Sequential load no error processed")
                        completion(result: .Failure(error))
                    }
                }
            }
        } else {
            self.updateValueAndError()
            if let value = self.value {
                completion(result: .Success(value))
            } else {
                let error = NSError(domain: "LoadAction[Group]", code: 2914, description: "Sequential load no value processed")
                completion(result: .Failure(error))
            }
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
                self.updateValueAndError()
                if self.actions.find({ $0.status != .Ready }) == nil {
                    if let error = self.error { // self.actions.find({ $0.error != nil }) == nil
                        completion(result: .Failure(error))
                    } else if let value = self.value {
                        completion(result: .Success(value))
                    } else {
                        let error = NSError(domain: "LoadAction[Group]", code: 2915, description: "Parallel load no value processed")
                        completion(result: .Failure(error))
                    }
                } else {
                    self.sendDelegateUpdates()
                }
            }
        }
    }
    
    private func updateValueAndError() {
        error = processErrorClosure(actions: actions)
        value = processValueClosure(actions: actions)
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
        if let processValue = processValue {
            self.processValueClosure = processValue
        } else {
            self.processValueClosure = GroupLoadAction.defaultProcessValueIgnore()
        }
        if let processError = processError {
            self.processErrorClosure = processError
        } else {
            self.processErrorClosure = GroupLoadAction.defaultProcessErrorFirst()
        }
        super.init(
            load: { _ in },
            delegates: delegates
        )
        loadClosure = { (result) -> Void in
            self.loadInner(completion: result)
        }
    }
    
    private class func defaultProcessErrorFirst() -> ProcessError {
        return { (actions: [LoadActionLoadableType]) -> ErrorType? in
            return actions.find({ $0.error != nil })?.error
        }
    }
    
    private class func defaultProcessValueLast() -> ProcessValue {
        return { (actions: [LoadActionLoadableType]) -> T? in
            return actions.reverse().find({ $0.valueAny as? T != nil })?.valueAny as? T
        }
    }
    
    private class func defaultProcessValueIgnore() -> ProcessValue {
        return { (actions: [LoadActionLoadableType]) -> T? in
            return (IgnoreValue() as! T)
        }
    }
    
}


//public class GroupLoadAction2: LoadAction<IgnoreValue> {
//    
//    public typealias GroupLoadedResultType    = Result<IgnoreValue, ErrorType>
//    public typealias GroupLoadedResultClosure = (result: GroupLoadedResultType) -> Void
//    public typealias GroupLoadedResult        = (completion: GroupLoadedResultClosure) -> Void
//    
//    public  var order:          GroupLoadOrder
//    public  var actions:       [LoadActionLoadableType]
//    private var actionsToLoad: [LoadActionLoadableType] = []
//    
//    /**
//     Loads data giving the option of paging or loading new.
//     
//     - parameter forced: If true forces main load
//     - parameter completion: Closure called when operation finished
//     */
//    private func loadInner(completion completion: GroupLoadedResultClosure) {
//        
//        // Copy load actions
//        actionsToLoad = actions
//        
//        // choose loading function
//        switch order {
//        case .Sequential, .SequentialForced:
//            loadSequential(completion: completion)
//        case .Parallel:
//            loadParallel(completion: completion)
//        }
//        
//    }
//    
//    /**
//     Loads data giving the option of paging or loading new.
//     
//     - parameter forced: If true forces main load
//     - parameter completion: Closure called when operation finished
//     */
//    private func loadSequential(completion completion: GroupLoadedResultClosure) {
//        if let actionToLoad = actionsToLoad.popFirst() {
//            actionToLoad.loadAny() { (result) -> Void in
//                if result.isSuccess || self.order != .SequentialForced {
//                    if self.actionsToLoad.count > 0 { self.sendDelegateUpdates() }
//                    self.loadSequential(completion: completion)
//                } else {
//                    self.actionsToLoad = []
//                    let error = NSError(domain: "LoadAction[Group]", code: 2913, description: "Sequential load error")
//                    completion(result: .Failure(error))
//                }
//            }
//        } else {
//            completion(result: .Success(IgnoreValue()))
//        }
//    }
//    
//    /**
//     Loads data giving the option of paging or loading new.
//     
//     - parameter forced: If true forces main load
//     - parameter completion: Closure called when operation finished
//     */
//    private func loadParallel(completion completion: GroupLoadedResultClosure) {
//        while let actionToLoad = actionsToLoad.popFirst() {
//            actionToLoad.loadAny() { (result) -> Void in
//                if self.actions.find({ $0.status != .Ready }) == nil {
//                    completion(result: .Success(IgnoreValue()))
//                } else {
//                    self.sendDelegateUpdates()
//                }
//            }
//        }
//    }
//    
//    /**
//     Quick initializer with all closures
//     
//     - parameter limitOnce: Only load one time automatically (does allow reload when called specifically)
//     - parameter shouldUpdateCache: Load from cache before loading from web
//     - parameter loadCache: Closure to load from cache, must call result closure when finished
//     - parameter load: Closure to load from web, must call result closure when finished
//     - parameter delegates: Array containing objects that react to updated data
//     */
//    public init(
//        order:             GroupLoadOrder = .Parallel,
//        actions:          [LoadActionLoadableType],
//        delegates:        [LoadActionDelegate] = [],
//        dummy:             (() -> ())? = nil)
//    {
//        self.order = order
//        self.actions = actions
//        super.init(
//            load: { _ in },
//            delegates: delegates
//        )
//        loadClosure = { (result) -> Void in
//            self.loadInner(completion: result)
//        }
//    }
//    
//}