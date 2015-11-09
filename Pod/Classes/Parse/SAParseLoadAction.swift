//
//  SAParseLoadAction.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 12/4/14.
//  Copyright (c) 2014 StartApps. All rights reserved.
//  Version 2.0
//

import Foundation
import Parse

public class SAParseLoadAction<T: CustomStringConvertible>: SALoadAction<T> {
    
    public typealias QueryType = () -> Void
    public typealias LoadedQueryErrorType  = (query: PFQuery?, error: NSError?) -> Void
    public typealias LoadedQueryResultType = (result: LoadedQueryErrorType) -> Void
    public typealias LoadedRawResultType   = (loadedDataRaw: AnyObject, result: LoadedDataErrorType) -> Void
    
    var queryClosure:       LoadedQueryResultType
    var queryLoadedClosure: LoadedRawResultType
    
    func loadCacheParse(result: (loadedData: T?, error: NSError?) -> Void) {
        if !Parse.isLocalDatastoreEnabled() {
            result(loadedData: nil, error: nil)
            return
        }
        queryClosure() { (query, error) -> Void in
            if let error = error {
                result(loadedData: nil, error: error)
                return
            }
            log(owner:"LoadAction[Parse]", value: "Cache Load (class: \(query!.parseClassName))", level: .Info)
            query!.fromLocalDatastore()
            query!.findObjectsInBackgroundWithBlock() { (parseObjects, error) -> Void in
                if let error = error {
                    result(loadedData: nil, error: error)
                } else if let loadedDataRaw = parseObjects {
                    self.queryLoadedClosure(loadedDataRaw: loadedDataRaw) { (loadedData, error) -> Void in
                        log(owner:"LoadAction[Parse]", value: "Cache Load Got (objects: \(loadedData))", level: .Verbose)
                        result(loadedData: loadedData, error: error)
                    }
                } else {
                    log(owner:"LoadAction[Parse]", value: "Cache Load Error (objects: \(parseObjects))", level: .Error)
                    result(loadedData: nil, error: NSError(domain: "SAParseLoadAction", code: 732, userInfo: [NSLocalizedDescriptionKey: "Objetos recibidos incorrectos"]))
                }
            }
        }
    }
    
    func loadParse(result: LoadedDataErrorType) {
        queryClosure() { (query, error) -> Void in
            if let error = error {
                result(loadedData: nil, error: error)
                return
            }
            log(owner:"LoadAction[Parse]", value: "Main Load (class: \(query!.parseClassName))", level: .Info)
            query!.findObjectsInBackgroundWithBlock() { (parseObjects, error) -> Void in
                if let error = error {
                    result(loadedData: nil, error: error)
                } else if let loadedDataRaw = parseObjects {
                    if Parse.isLocalDatastoreEnabled() { PFObject.pinAllInBackground(parseObjects, block: nil) }
                    self.queryLoadedClosure(loadedDataRaw: loadedDataRaw) { (loadedData, error) -> Void in
                        log(owner:"LoadAction[Parse]", value: "Main Load Got (objects: \(loadedData))", level: .Verbose)
                        result(loadedData: loadedData, error: error)
                    }
                } else {
                    log(owner:"LoadAction[Parse]", value: "Main Load Error (objects: \(parseObjects))", level: .Error)
                    result(loadedData: nil, error: NSError(domain: "SAParseLoadAction", code: 733, userInfo: [NSLocalizedDescriptionKey: "Objetos recibidos incorrectos"]))
                }
            }
        }
    }
    
    /**
     Quick initializer with all closures
     
     - parameter loadOnce: Only load one time automatically (does allow reload when called specifically)
     - parameter allowCache: Load from cache before loading from web
     - parameter query: PFQuery object that gets the data
     - parameter updateView: Closure to update the view when something has changed
     */
    public init(
        loadOnce:          Bool = false,
        shouldUpdateCache: LoadedDataReturnType? = nil,
        query:             LoadedQueryResultType,
        queryLoaded:       LoadedRawResultType,
        updateView:        LoadedStatusDataType? = nil,
        dummy:             (() -> ())? = nil)
    {
        self.queryClosure = query
        self.queryLoadedClosure = queryLoaded
        super.init(
            loadOnce: loadOnce,
            shouldUpdateCache: shouldUpdateCache,
            loadCache: { (result) -> () in },
            load: { (result) -> () in },
            updateView: updateView
        )
        loadCacheClosure = { (result) -> () in
            self.loadCacheParse(result)
        }
        loadClosure = { (result) -> () in
            self.loadParse(result)
        }
    }
    
}



/********************************************************************************************************/
 // MARK: Push Extension
 /********************************************************************************************************/

extension Parse {
    
    class func registerPush() {
        let application = UIApplication.sharedApplication()
        if #available(iOS 8.0, *) {
            // Register for Push Notitications, if running iOS 8
            let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound])
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // Register for Push Notifications before iOS 8
            let userNotificationTypes: UIRemoteNotificationType = ([UIRemoteNotificationType.Alert, UIRemoteNotificationType.Badge, UIRemoteNotificationType.Sound])
            application.registerForRemoteNotificationTypes(userNotificationTypes)
        }
    }
    
}


/********************************************************************************************************/
 // MARK: GeoPoint Extension
 /********************************************************************************************************/

extension PFGeoPoint {
    
    var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2DMake(latitude, longitude) }
    var coreLocation: CLLocation { return CLLocation(latitude: latitude, longitude: longitude) }
    
}

extension CLLocation {
    
    var geoPoint: PFGeoPoint { return PFGeoPoint(location: self) }
    
}