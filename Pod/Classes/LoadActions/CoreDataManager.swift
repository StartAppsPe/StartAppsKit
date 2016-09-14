//
//  CoreDataManager.swift
//  ULima
//
//  Created by Gabriel Lanata on 2/2/15.
//  Copyright (c) 2015 is.oto.pe. All rights reserved.
//
 
import CoreData

open class CoreDataManager {
    
    // MARK: - Core Data stack
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "dddddd")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    open lazy var applicationDocumentsDirectory: URL = self.innerApplicationDocumentsDirectory()
    fileprivate func innerApplicationDocumentsDirectory() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }
    
    open lazy var managedObjectModel: NSManagedObjectModel = self.innerManagedObjectModel()
    fileprivate func innerManagedObjectModel() -> NSManagedObjectModel {
        let modelURL = Bundle.main.url(forResource: "CoreData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }
    
    open lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = self.innerPersistentStoreCoordinator()
    fileprivate func innerPersistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("CoreData.sqlite")
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: mOptions)
        } catch let error as NSError {
            coordinator = nil
            print(owner: "CoreData", items: "Error on persistentStoreCoordinator \(error), \(error.userInfo)", level: .error)
            abort()
        } catch {
            fatalError()
        }
        return coordinator
    }
    
    open lazy var managedObjectContext: NSManagedObjectContext? = self.innerManagedObjectContext()
    fileprivate func innerManagedObjectContext() -> NSManagedObjectContext? {
        guard let coordinator = self.persistentStoreCoordinator else { return nil }
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }
    
    open class func create(entityName: String) -> NSManagedObject {
        if let managedContext = CoreDataManager.sharedInstance.managedObjectContext {
            if let entity =  NSEntityDescription.entity(forEntityName: entityName, in: managedContext) {
                print(owner: "CoreData", items: "Created object (\(entityName))", level: .info)
                return NSManagedObject(entity: entity, insertInto: managedContext)
            } else {
                print(owner: "CoreData", items: "Create object failed because no entityDescription (\(entityName))", level: .error)
            }
        } else {
            print(owner: "CoreData", items: "Create object failed because no managedContext", level: .error)
        }
        assertionFailure("Error, should not have gotten here")
        return NSManagedObject()
    }
    
    open class func save() {
        if let managedContext = CoreDataManager.sharedInstance.managedObjectContext {
            if managedContext.hasChanges {
                DispatchQueue.main.async {
                    print(owner: "CoreData", items: "Saving", level: .verbose)
                    do {
                        try managedContext.save()
                        print(owner: "CoreData", items: "Saved data", level: .info)
                    } catch let error as NSError {
                        print(owner: "CoreData", items: "Save data failed \(error), \(error.userInfo)", level: .error)
                    } catch {
                        fatalError()
                    }
                }
            } else {
                print(owner: "CoreData", items: "Save data skipped because no changes", level: .warning)
            }
        } else {
            print(owner: "CoreData", items: "Save data failed because no managedContext", level: .error)
        }
    }
    
    open class func delete(object: NSManagedObject) {
        if let managedContext = CoreDataManager.sharedInstance.managedObjectContext {
            print(owner: "CoreData", items: "Deleted object", level: .warning)
            managedContext.delete(object)
        } else {
            print(owner: "CoreData", items: "Delete data failed because no managedContext", level: .error)
        }
    }
    
    open class func fetch<T : NSFetchRequestResult>(_ entity: T.Type, entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T]? {
        if let managedContext = CoreDataManager.sharedInstance.managedObjectContext {
            let fetchRequest = NSFetchRequest<T>(entityName: entityName)
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.predicate = predicate
            do {
                return try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print(owner: "CoreData", items: "Fetch failed \(error), \(error.userInfo)", level: .error)
            } catch {
                fatalError()
            }
        } else {
            print(owner: "CoreData", items: "Fetch failed because no managedContext", level: .error)
        }
        return nil
    }
    
}

public extension NSManagedObject { // Quitar en Swift 2.0
    
    public class func create<T:NSManagedObject>(_ entity: T.Type) -> T where T:ClassNameable {
        return CoreDataManager.create(entityName: T.className) as! T
    }
    
    public class func create<T:NSManagedObject>(_ entity: T.Type, uid: String) -> T where T:UniquedObject {
        var obj = create(entity)
        obj.uid = uid
        return obj
    }
    
    public class func fetch<T:NSManagedObject>(_ entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T]? where T:ClassNameable {
        return CoreDataManager.fetch(entity, entityName: T.className, predicate: predicate, sortDescriptors: sortDescriptors)
    }
    
    public class func fetchSingle<T:NSManagedObject>(_ entity: T.Type, predicate: NSPredicate? = nil) -> T? {
        return fetch(entity, predicate: predicate)?.first
    }
    
    public class func fetchSingle<T:NSManagedObject>(_ entity: T.Type, uid: String) -> T? where T:UniquedObject {
        return fetchSingle(entity, predicate: NSPredicate(format: "uid == %@", uid))
    }
    
    public class func fetchSingleOrCreate<T:NSManagedObject>(_ entity: T.Type, uid: String) -> T where T:UniquedObject {
        return fetchSingle(entity, uid: uid) ?? create(entity, uid: uid)
    }
    
    public func delete() {
        CoreDataManager.delete(object: self)
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
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public var className: String {
        return type(of: self).className
    }
    
}
