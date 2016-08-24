//
//  CoreDataLoadAction.swift
//  ULima
//
//  Created by Gabriel Lanata on 1/7/16.
//  Copyright © 2016 Universidad de Lima. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataLoadActionSingle<U: NSManagedObject>: LoadAction<U> {
    
    public var predicate:       NSPredicate?
    public var sortDescriptors: [NSSortDescriptor]?
    
    private func loadInner(completion completion: LoadResultClosure) {
        if let loadedValue = NSManagedObject.fetchAll(U.self, predicate: predicate, sortDescriptors: sortDescriptors) {
            completion(result: Result.Success(loadedValue.first))
        } else {
            let error = NSError(domain: "LoadAction[CoreData]", code: 542, description: "Error when fetching from database")
            completion(result: .Failure(error))
        }
    }
    
    public init(
        predicate:       NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        delegates:       [LoadActionDelegate] = [],
        dummy:           (() -> ())? = nil)
    {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        super.init(
            load:      { _ in },
            delegates: delegates
        )
        loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
    }
    
}

public class CoreDataLoadAction<U: NSManagedObject>: LoadAction<[U]> {
    
    public var predicate:       NSPredicate?
    public var sortDescriptors: [NSSortDescriptor]?
    
    private func loadInner(completion completion: LoadResultClosure) {
        if let loadedValue = NSManagedObject.fetchAll(U.self, predicate: predicate, sortDescriptors: sortDescriptors) {
            completion(result: Result.Success(loadedValue))
        } else {
            let error = NSError(domain: "LoadAction[CoreData]", code: 542, description: "Error when fetching from database")
            completion(result: .Failure(error))
        }
    }
    
    public init(
        predicate:       NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        delegates:       [LoadActionDelegate] = [],
        dummy:           (() -> ())? = nil)
    {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        super.init(
            load:      { _ in },
            delegates: delegates
        )
        loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
    }
    
}
