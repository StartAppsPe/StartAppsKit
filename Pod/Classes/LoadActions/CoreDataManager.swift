//
//  CoreDataManager.swift
//  ULima
//
//  Created by Gabriel Lanata on 2/2/15.
//  Copyright (c) 2015 is.oto.pe. All rights reserved.
//
 
import CoreData

public class CoreDataManager {
    
    public lazy var applicationDocumentsDirectory: NSURL = self.innerApplicationDocumentsDirectory()
    private func innerApplicationDocumentsDirectory() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }
    
    public lazy var managedObjectModel: NSManagedObjectModel = self.innerManagedObjectModel()
    private func innerManagedObjectModel() -> NSManagedObjectModel {
        let modelURL = NSBundle.mainBundle().URLForResource("CoreData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = self.innerPersistentStoreCoordinator()
    private func innerPersistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreData.sqlite")
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: mOptions)
        } catch let error as NSError {
            coordinator = nil
            print(owner: "CoreData", items: "Error on persistentStoreCoordinator \(error), \(error.userInfo)", level: .Error)
            abort()
        } catch {
            fatalError()
        }
        return coordinator
    }
    
    public lazy var managedObjectContext: NSManagedObjectContext? = self.innerManagedObjectContext()
    private func innerManagedObjectContext() -> NSManagedObjectContext? {
        guard let coordinator = self.persistentStoreCoordinator else { return nil }
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }
    
    public class func create(entityName: String) -> NSManagedObject {
        if let managedContext = CoreDataManager.sharedInstance.managedObjectContext {
            if let entity =  NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext) {
                print(owner: "CoreData", items: "Created object (\(entityName))", level: .Info)
                return NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedContext)
            } else {
                print(owner: "CoreData", items: "Create object failed because no entityDescription (\(entityName))", level: .Error)
            }
        } else {
            print(owner: "CoreData", items: "Create object failed because no managedContext", level: .Error)
        }
        assertionFailure("Error, should not have gotten here")
        return NSManagedObject()
    }
    
    public class func save() {
        if let managedContext = CoreDataManager.sharedInstance.managedObjectContext {
            if managedContext.hasChanges {
                dispatch_async(dispatch_get_main_queue()) {
                    print(owner: "CoreData", items: "Saving", level: .Verbose)
                    do {
                        try managedContext.save()
                        print(owner: "CoreData", items: "Saved data", level: .Info)
                    } catch let error as NSError {
                        print(owner: "CoreData", items: "Save data failed \(error), \(error.userInfo)", level: .Error)
                    } catch {
                        fatalError()
                    }
                }
            } else {
                print(owner: "CoreData", items: "Save data skipped because no changes", level: .Warning)
            }
        } else {
            print(owner: "CoreData", items: "Save data failed because no managedContext", level: .Error)
        }
    }
    
    public class func delete(object: NSManagedObject) {
        if let managedContext = CoreDataManager.sharedInstance.managedObjectContext {
            print(owner: "CoreData", items: "Deleted object", level: .Warning)
            managedContext.deleteObject(object)
        } else {
            print(owner: "CoreData", items: "Delete data failed because no managedContext", level: .Error)
        }
    }
    
    public class func fetch(entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [NSManagedObject]? {
        if let managedContext = CoreDataManager.sharedInstance.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: entityName)
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.predicate = predicate
            do {
                return try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            } catch let error as NSError {
                print(owner: "CoreData", items: "Fetch failed \(error), \(error.userInfo)", level: .Error)
            } catch {
                fatalError()
            }
        } else {
            print(owner: "CoreData", items: "Fetch failed because no managedContext", level: .Error)
        }
        return nil
    }
    
}

public extension NSManagedObject { // Quitar en Swift 2.0
    
    public class func create<T:NSManagedObject where T:ClassNameable>(entity: T.Type) -> T {
        return CoreDataManager.create(T.className) as! T
    }
    
    public class func create<T:NSManagedObject where T:UniquedObject>(entity: T.Type, uid: String) -> T {
        var obj = create(entity)
        obj.uid = uid
        return obj
    }
    
    public class func fetch<T:NSManagedObject where T:ClassNameable>(entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T]? {
        return CoreDataManager.fetch(T.className, predicate: predicate, sortDescriptors: sortDescriptors) as? [T]
    }
    
    public class func fetchSingle<T:NSManagedObject>(entity: T.Type, predicate: NSPredicate? = nil) -> T? {
        return fetch(entity, predicate: predicate)?.first
    }
    
    public class func fetchSingle<T:NSManagedObject where T:UniquedObject>(entity: T.Type, uid: String) -> T? {
        return fetchSingle(entity, predicate: NSPredicate(format: "uid == %@", uid))
    }
    
    public class func fetchSingleOrCreate<T:NSManagedObject where T:UniquedObject>(entity: T.Type, uid: String) -> T {
        return fetchSingle(entity, uid: uid) ?? create(entity, uid: uid)
    }
    
    public func delete() {
        CoreDataManager.delete(self)
    }
    
    public func save() {
        CoreDataManager.save()
    }
    
}


// Singleton Methods
public extension CoreDataManager {
    public static let sharedInstance = CoreDataManager()
}

public protocol UniquedObject {
    var uid: String { get set }
}


extension NSManagedObject: ClassNameable { }

public protocol ClassNameable: class {
    
    static var className: String { get }
    
    var className: String { get }
    
}

public extension ClassNameable {
    
    public static var className: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public var className: String {
        return self.dynamicType.className
    }
    
}
