//
//  SAStaticTableViewController.swift
//  ULima Eventos
//
//  Created by Gabriel Lanata on 4/30/15.
//  Copyright (c) 2015 Universidad de Lima. All rights reserved.
//

import UIKit

public protocol SAStaticTableViewControllerSubclass: SASectionedTableViewControllerSubclass {
    
    /*OPTIONAL*/ var staticTableViewControllerSubclass: SAStaticTableViewControllerSubclass! { get }
    
    /*REQUIRED*/ func staticObjects(tableView tableView: UITableView) -> [SATableObjectsSection]?
    
}

public class SAStaticTableViewController: SATableViewController {
    
    public var staticTableViewControllerSubclass: SAStaticTableViewControllerSubclass!
    
    /********************************************************************************************************/
    // MARK: View Management Methods
    /********************************************************************************************************/
    
    public override func viewDidLoad() {
        
        // Set subclasses
        staticTableViewControllerSubclass = self as! SAStaticTableViewControllerSubclass
        
        // Call super
        super.viewDidLoad()
    }
    
    /********************************************************************************************************/
    // MARK: SATableViewController Subclass
    /********************************************************************************************************/
    
    func loadingStatus(tableView tableView: UITableView, section: Int?) -> LoadingStatus {
        return loadActions.loadingStatus
    }
    
    func loadingStatusInfoGroup(tableView tableView: UITableView, section: Int?) -> LoadingStatusInfoGroup {
        return LoadingStatusInfoGroup(
            emptyInfo: LoadingStatusInfo(title: "No hay información")
        )
    }
    
    func objects(tableView tableView: UITableView) -> [AnyObject]? {
        if let staticObjects = staticTableViewControllerSubclass.staticObjects(tableView: tableView) {
            return staticObjects.map { return $0.objects }
        }
        return nil
    }
    
    func cellIdentifier(tableView tableView: UITableView, indexPath: NSIndexPath) -> String {
        return (object(tableView: tableView, indexPath: indexPath) as? SATableObject)!.cellIdentifier
    }
    
    func formatCell(tableView tableView: UITableView, cell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        if let tableViewCell = cell as? SATableViewCell, tableObject = object as? SATableObject {
            tableViewCell.tableObject = tableObject
            tableViewCell.accessoryType = (tableObject.onSelection != nil ? .DisclosureIndicator : .None)
            tableObject.customization?(cell: tableViewCell)
        }
    }
    
    func selectedRow(tableView tableView: UITableView, object: AnyObject, indexPath: NSIndexPath) {
        if let tableObject = object as? SATableObject {
            tableObject.onSelection?()
        }
    }
    
    public override func shouldHighlightRow(tableView tableView: UITableView, object: AnyObject, indexPath: NSIndexPath) -> Bool {
        if let tableObject = object as? SATableObject {
            if let _ = tableObject.onSelection {
                return true
            }
        }
        return false
    }
    
    /********************************************************************************************************/
    // MARK: SASectionedTableViewController Subclass
    /********************************************************************************************************/
    
    func headerForSection(tableView tableView: UITableView, section: Int) -> String? {
        if let staticObjects = staticTableViewControllerSubclass.staticObjects(tableView: tableView) {
            return staticObjects[section].header
        }
        return nil
    }
    
}
