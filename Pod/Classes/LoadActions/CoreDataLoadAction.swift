//
//  CoreDataLoadAction.swift
//  ULima
//
//  Created by Gabriel Lanata on 1/7/16.
//  Copyright © 2016 Universidad de Lima. All rights reserved.
//

import Foundation
import CoreData

open class CoreDataLoadActionSingle<U: NSManagedObject>: LoadAction<U?> {
    
    open var predicate:       NSPredicate?
    open var sortDescriptors: [NSSortDescriptor]?
    
    fileprivate func loadInner(completion: LoadResultClosure) {
        print(owner: "LoadAction[CoreData1]", items: "Load Began", level: .info)
        if let loadedValue = NSManagedObject.fetch(U.self, predicate: predicate, sortDescriptors: sortDescriptors) {
            print(owner: "LoadAction[CoreData]", items: "Load Success", level: .info)
            completion(.success(loadedValue.first))
        } else {
            let error = NSError(domain: "LoadAction[CoreData]", code: 542, description: "Error when fetching from database")
            print(owner: "LoadAction[CoreData]", items: "Load Failure. \(error)", level: .error)
            completion(.failure(error))
        }
    }
    
    public init(
        predicate:       NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        dummy:           (() -> ())? = nil)
    {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        super.init(
            load:      { _ in }
        )
        loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
    }
    
}

open class CoreDataLoadAction<U: NSManagedObject>: LoadAction<[U]> {
    
    open var predicate:       NSPredicate?
    open var sortDescriptors: [NSSortDescriptor]?
    
    fileprivate func loadInner(completion: LoadResultClosure) {
        print(owner: "LoadAction[CoreData]", items: "Load Began", level: .info)
        if let loadedValue = NSManagedObject.fetch(U.self, predicate: predicate, sortDescriptors: sortDescriptors) {
            print(owner: "LoadAction[CoreData]", items: "Load Success", level: .info)
            completion(.success(loadedValue))
        } else {
            let error = NSError(domain: "LoadAction[CoreData]", code: 543, description: "Error when fetching from database")
            print(owner: "LoadAction[CoreData]", items: "Load Failure. \(error)", level: .error)
            completion(.failure(error))
        }
    }
    
    public init(
        predicate:       NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        dummy:           (() -> ())? = nil)
    {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        super.init(
            load:      { _ in }
        )
        loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
    }
    
}
