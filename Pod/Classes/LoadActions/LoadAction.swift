//
//  LoadAction.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 9/17/15.
//  Copyright (c) 2014 StartApps. All rights reserved.
//  Version: 1.0
//

import Foundation

public class ConvertLoadAction<A, B, T>: ProcessLoadAction<B, T> {
    
    public typealias ConvertResultType    = Result<B, ErrorType>
    public typealias ConvertResultClosure = (result: ConvertResultType) -> Void
    public typealias ConvertResult        = (loadedValue: A, completion: ConvertResultClosure) -> Void
    
    public var convertClosure: ConvertResult
    
    public var baseLoadAction: LoadAction<A>
    
    private func loadRawInner(completion completion: LoadRawResultClosure) {
        baseLoadAction.load() { (result) in
            switch result {
            case .Failure(let error):
                completion(result: Result.Failure(error))
            case .Success(let value):
                self.convertClosure(loadedValue: value, completion: completion)
            }
        }
    }
    
    public class func automaticConvert() -> ConvertResult {
        return { (loadedValue: A, completion: ConvertResultClosure) in
            if let loadedValue = loadedValue as? B {
                completion(result: Result.Success(loadedValue))
            } else {
                let error = NSError(domain: "LoadAction[Convert]", code: 432, description: "Could not automatically convert value")
                completion(result: Result.Failure(error))
            }
        }
    }
    
    public init(
        baseLoadAction: LoadAction<A>,
        convert:        ConvertResult?,
        process:        ProcessResult?,
        delegates:      [LoadActionDelegate] = [],
        dummy:          (() -> ())? = nil)
    {
        self.baseLoadAction    = baseLoadAction
        if let convertClosure = convert {
            self.convertClosure = convertClosure
        } else {
            self.convertClosure = ConvertLoadAction<A, B, T>.automaticConvert()
        }
        super.init(
            loadRaw:   { _ in },
            process:   process,
            delegates: delegates
        )
        self.loadRawClosure = { (completion) -> Void in
            self.loadRawInner(completion: completion)
        }
    }
    
}

public class ProcessLoadAction<B, T>: LoadAction<T> {
    
    public typealias LoadRawResultType    = Result<B, ErrorType>
    public typealias LoadRawResultClosure = (result: LoadRawResultType) -> Void
    public typealias LoadRawResult        = (completion: LoadRawResultClosure) -> Void
    
    public typealias ProcessResultType    = Result<T, ErrorType>
    public typealias ProcessResultClosure = (result: ProcessResultType) -> Void
    public typealias ProcessResult        = (loadedValue: B, completion: ProcessResultClosure) -> Void
    
    public var loadRawClosure: LoadRawResult
    public var processClosure: ProcessResult
    
    
    private func loadInner(completion completion: LoadResultClosure) {
        loadRawClosure() { (result) in
            switch result {
            case .Failure(let error):
                completion(result: Result.Failure(error))
            case .Success(let loadedValue):
                self.processClosure(loadedValue: loadedValue, completion: completion)
            }
        }
    }
    
    public class func automaticProcess() -> ProcessResult {
        return { (loadedValue: B, completion: ProcessResultClosure) in
            if let loadedValue = loadedValue as? T {
                completion(result: Result.Success(loadedValue))
            } else {
                let error = NSError(domain: "LoadAction[Process]", code: 432, description: "Could not automatically process value")
                completion(result: Result.Failure(error))
            }
        }
    }
    
    /**
     Quick initializer with all closures
     
     - parameter load: Closure to load from web, must call result closure when finished
     - parameter delegates: Array containing objects that react to updated data
     */
    public init(
        loadRaw:   LoadRawResult,
        process:   ProcessResult?,
        delegates: [LoadActionDelegate] = [],
        dummy:     (() -> ())? = nil)
    {
        self.loadRawClosure = loadRaw
        if let processClosure = process {
            self.processClosure = processClosure
        } else {
            self.processClosure = ProcessLoadAction<B, T>.automaticProcess()
        }
        super.init(
            load:      { _ in },
            delegates: delegates
        )
        self.loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
    }
    
}

public class LoadAction<T>: LoadActionType {
    
    public typealias LoadResultType     = Result<T, ErrorType>
    public typealias LoadResultClosure  = (result: LoadResultType) -> Void
    public typealias LoadResult         = (completion: LoadResultClosure) -> Void
    
    public var updatedProperties: Set<LoadActionProperties> = []
    public var delegates: [LoadActionDelegate] = []
    
    public var status: LoadingStatus = .Ready {
        didSet { updatedProperties.insert(.Status) }
    }
    public var error: ErrorType? {
        didSet { updatedProperties.insert(.Error) }
    }
    public var value: T? {
        didSet { updatedProperties.insert(.Value); date = NSDate() }
    }
    public var date: NSDate? {
        didSet { updatedProperties.insert(.Date) }
    }
    
    public var loadClosure: LoadResult!
    
    /**
     Loads value giving the option of paging or loading new.
     
     - parameter completion: Closure called when operation finished
     */
    public func load(completion completion: LoadResultClosure?) {
        print(owner: "LoadAction", items: "Load Began", level: .Info)
        
        // Adjust loading status to loading kind
        status = .Loading
        sendDelegateUpdates()
        
        // Load value
        loadClosure() { (result) -> () in
            
            switch result {
            case .Failure(let error):
                print(owner: "LoadAction", items: "Loaded = Error \(error)", level: .Error)
                self.error = error
            case .Success(let loadedValue):
                print(owner: "LoadAction", items: "Loaded = Value \(loadedValue)", level: .Info)
                self.value = loadedValue
            }
            
            // Adjust loading status to loaded kind and call completion
            self.status = .Ready
            self.sendDelegateUpdates()
            completion?(result: result)
        }
        
    }
    
    public func loadAny(completion completion: ((result: Result<Any, ErrorType>) -> Void)?) {
        load() { (resultGeneric) -> Void in
            switch resultGeneric {
            case .Success(let loadedValue):
                completion?(result: Result.Success(loadedValue))
            case .Failure(let error):
                completion?(result: Result.Failure(error))
            }
        }
    }
    
    /**
     Quick initializer with all closures
     
     - parameter load: Closure to load from web, must call result closure when finished
     - parameter delegates: Array containing objects that react to updated value
     */
    public init(
        load:       LoadResult,
        delegates: [LoadActionDelegate] = [],
        dummy:      (() -> ())? = nil)
    {
        self.loadClosure    = load
        self.delegates      = delegates
    }
    
}

