//
//  SATableViewController.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 12/10/15.
//  Copyright (c) 2015 StartApps. All rights reserved.
//
/*
import UIKit

public protocol SATableViewControllerSubclass: SAViewControllerSubclass {
    
    /*OPTIONAL*/ var tableViewControllerSubclass: SATableViewControllerSubclass! { get }
    
    /*OPTIONAL*/ var tableView: UITableView! { get }
    /*OPTIONAL*/ var refreshControl: UIRefreshControl? { get }
    
    /*OPTIONAL*/ var headerView: UIView? { get }
    /*OPTIONAL*/ var headerViewHeightLayoutConstraint: NSLayoutConstraint? { get }
    /*OPTIONAL*/ var headerViewDefaultHeight: CGFloat? { get }
    
    /*REQUIRED*/ func loadingStatus(tableView tableView: UITableView, section: Int?) -> LoadingStatus
    /*REQUIRED*/ //func loadingStatusInfoGroup(tableView tableView: UITableView, section: Int?) -> LoadingStatusInfoGroup
    
    /*REQUIRED*/ func objects(tableView tableView: UITableView) -> [Any]?
    /*OPTIONAL*/ func object(tableView tableView: UITableView, indexPath: NSIndexPath) -> Any?
    
    /*REQUIRED*/ func cellIdentifier(tableView tableView: UITableView, object: Any, indexPath: NSIndexPath) -> String
    /*REQUIRED*/ func formattedCell(tableView tableView: UITableView, cell: UITableViewCell, object: Any, indexPath: NSIndexPath) -> UITableViewCell
    
    /*OPTIONAL*/ func heightForObject(tableView tableView: UITableView, object: Any, indexPath: NSIndexPath) -> CGFloat?
    /*OPTIONAL*/ func heightEstimateForObject(tableView tableView: UITableView, object: Any, indexPath: NSIndexPath) -> CGFloat?
    
    /*OPTIONAL*/ func shouldHighlightObject(tableView tableView: UITableView, object: Any, indexPath: NSIndexPath) -> Bool
    /*REQUIRED*/ func didSelectObject(tableView tableView: UITableView, object: Any, indexPath: NSIndexPath)
    /*OPTIONAL*/ func didDeselectObject(tableView tableView: UITableView, object: Any, indexPath: NSIndexPath)
    /*OPTIONAL*/ func didSelectObjectAccessory(tableView tableView: UITableView, object: Any, indexPath: NSIndexPath)
}

public protocol SASectionedTableViewControllerSubclass: SATableViewControllerSubclass {
    
    /*OPTIONAL*/ var sectionedTableViewControllerSubclass: SASectionedTableViewControllerSubclass? { get }
    
    /*OPTIONAL*/ func objects(tableView tableView: UITableView, section: Int) -> [Any]?
    
    /*REQUIRED*/ func sectionTitle(tableView tableView: UITableView, section: Int) -> String?
    
}

public protocol SASearchableTableViewControllerSubclass: SATableViewControllerSubclass {
    
    /*OPTIONAL*/ var searchableTableViewControllerSubclass: SASearchableTableViewControllerSubclass? { get }
    
    /*REQUIRED*/ func cellIdentifierForSearch(tableView tableView: UITableView, object: Any, indexPath: NSIndexPath) -> String
    
    /*REQUIRED*/ //func objectsForSearch(tableView tableView: UITableView, searchString: String, result: LoadObjectsResult)
    /*REQUIRED*/ //func objectsForCacheSearch(tableView tableView: UITableView, searchString: String, result: LoadObjectsResult)
    
}

public class SATableViewController: SAViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet public weak var tableView: UITableView!
    public var refreshControl: UIRefreshControl?
    
    @IBOutlet public weak var headerView: UIView?
    @IBOutlet public weak var headerViewHeightLayoutConstraint: NSLayoutConstraint?
    public var headerViewDefaultHeight: CGFloat?
    
    public var tableViewControllerSubclass:           SATableViewControllerSubclass!
    public var sectionedTableViewControllerSubclass:  SASectionedTableViewControllerSubclass?
    public var searchableTableViewControllerSubclass: SASearchableTableViewControllerSubclass?
    
    /********************************************************************************************************/
     // MARK: View Management Methods
     /********************************************************************************************************/
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set subclasses
        tableViewControllerSubclass           = self as! SATableViewControllerSubclass
        sectionedTableViewControllerSubclass  = self as? SASectionedTableViewControllerSubclass
        searchableTableViewControllerSubclass = self as? SASearchableTableViewControllerSubclass
        
        // Set self as DataSource and Delegate
        tableView.dataSource = self
        tableView.delegate   = self
        
        // Setup refresh controller
        if let _ = tableViewControllerSubclass?.loadAction() {
            refreshControl = UIRefreshControl()
            refreshControl!.addTarget(self, action: "loadDataNew", forControlEvents: .ValueChanged)
            tableView.addSubview(refreshControl!)
        }
        
        // Setup header stretch default height
        headerViewDefaultHeight = headerViewHeightLayoutConstraint?.constant
        
        // Register InfoCell Nib
        //let nib = UINib(nibName: "SAInfoTableViewCell", bundle: nil)
        //tableView.registerNib(nib, forCellReuseIdentifier: "InfoCell")
        
    }
    
    /********************************************************************************************************/
     // MARK: Loading Data Methods
     /********************************************************************************************************/
    
    public override func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updatedValues: Set<LoadActionValues>) {
        switch loadAction.status {
        case .Loading, .Paging:
            // Do not stop refreshControl if started
            // Disabled because it causes gitter
            // TODO: Confirm behavious of this
            refreshControl?.beginRefreshing()
        case .Ready:
            refreshControl?.endRefreshing()
        }
        super.loadActionUpdated(loadAction: loadAction, updatedValues: updatedValues)
        tableView?.reloadData()
    }
    
    /********************************************************************************************************/
     // MARK: TableView Loading Status Methods
     /********************************************************************************************************/
    
    /*public func infoTableViewCellLoadingButtonPressed() {
        // Do nothing, subclass
    }
    
    public func infoTableViewCellEmptyButtonPressed() {
        newObject()
    }
    
    public func infoTableViewCellErrorButtonPressed() {
        loadData(forced: true)
    }*/
    
    /********************************************************************************************************/
     // MARK: TableView Header Methods
     /********************************************************************************************************/
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            if let headerViewHeightLayoutConstraint = headerViewHeightLayoutConstraint {
                headerViewHeightLayoutConstraint.constant = (headerViewDefaultHeight ?? 0)-scrollView.contentOffset.y
            }
        }
    }
    
    /********************************************************************************************************/
     // MARK: TableView Section Methods
     /********************************************************************************************************/
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //if tableView == searchDisplayController?.searchResultsTableView { return 1 }
        guard let objects = sectionedTableViewControllerSubclass?.objects(tableView: tableView) as? [[Any]] else { return 1 }
        return objects.count
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //if tableView == searchDisplayController?.searchResultsTableView { return nil }
        guard objects(tableView: tableView, section: section)?.count ?? 0 > 0 else { return nil }
        return sectionedTableViewControllerSubclass?.sectionTitle(tableView: tableView, section: section)
    }
    
    public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel!.font = UIFont.boldSystemFontOfSize(15)
            header.textLabel!.textAlignment = .Center
            header.textLabel!.frame = header.frame
        }
    }
    
    /********************************************************************************************************/
     // MARK: TableView Row Methods
     /********************************************************************************************************/
    
    public func objects(tableView tableView: UITableView, section: Int) -> [Any]? {
        if let subclass = sectionedTableViewControllerSubclass {
            return subclass.objects(tableView: tableView)?[section] as? [Any]
        } else if let subclass = tableViewControllerSubclass {
            return subclass.objects(tableView: tableView)
        }
        return nil
    }
    
    public func object(tableView tableView: UITableView, indexPath: NSIndexPath) -> Any? {
        return objects(tableView: tableView, section: indexPath.section)?[indexPath.row]
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if tableView == searchDisplayController?.searchResultsTableView { return searchObjects?.count ?? 0 }
        return min(objects(tableView: tableView, section: section)?.count ?? 0, 1)
    }
/*

    let HeightForRowAutomaticFillTable: CGFloat = -123456
    func heightForRow(tableView tableView: UITableView, object: Any, indexPath: NSIndexPath) -> CGFloat? {
        return nil
    }

    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //if UIDevice.currentDevice().systemVersion.compare("8.0", options: .NumericSearch) != .OrderedAscending { //Solo en > iOS 8
        //    return UITableViewAutomaticDimension;
        //}
        
        /*if tableView == searchDisplayController?.searchResultsTableView {
        return formattedCell(tableView: tableView, indexPath: indexPath, forSizing: true).autoLayoutHeight()
        }*/
        if let loadingStatus = tableViewControllerSubclass?.loadingStatus(tableView: tableView, section: indexPath.section) where !loadingStatus.hasData() {
            let tableViewHeight = tableView.frame.size.height-(tableView.tableHeaderView?.frame.size.height ?? 0)-(tableView.tableFooterView?.frame.size.height ?? 0)
            return tableViewHeight
        }
        //if indexPath.section == pagingSection { return 50 }
        let autoHeightForRow = formattedCell(tableView: tableView, indexPath: indexPath, forSizing: true).autoLayoutHeight(tableView)
        if let object: Any = object(tableView: tableView, indexPath: indexPath) {
            if let strictHeightForRow = heightForRow(tableView: tableView, object: object, indexPath: indexPath) {
                if strictHeightForRow == HeightForRowAutomaticFillTable {
                    let tableViewHeight = tableView.frame.size.height-(tableView.tableHeaderView?.frame.size.height ?? 0)-(tableView.tableFooterView?.frame.size.height ?? 0)
                    let rowCount = CGFloat(self.tableView(tableView, numberOfRowsInSection: indexPath.section))
                    let rowHeight = ceil(tableViewHeight/rowCount)
                    return min(max(rowHeight, autoHeightForRow), 100)
                }
                return strictHeightForRow
            }
        }
        return autoHeightForRow
    }
*/

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /*if tableView == searchDisplayController?.searchResultsTableView {
        return formattedCell(tableView: tableView, indexPath: indexPath)
        }*/
        guard let object = object(tableView: tableView, indexPath: indexPath) else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("InfoCell") //as! InfoTableViewCell
            //cell.loadingStatusInfoGroup = tableViewControllerSubclass!.loadingStatusInfoGroup(tableView: tableView, section: indexPath.section)
            //cell.loadingStatus = loadingStatus
            //cell.delegate = self
            // TODO: Do this
            return cell!
        }
        let cellIdentifier = tableViewControllerSubclass.cellIdentifier(tableView: tableView, object: object, indexPath: indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        return tableViewControllerSubclass.formattedCell(tableView: tableView, cell: cell, object: object, indexPath: indexPath)
}
/*

    var sizingCells = [String : UITableViewCell]()
    public func formattedCell(tableView tableView: UITableView, indexPath: NSIndexPath, forSizing: Bool = false) -> UITableViewCell {
        let cellIdentifier = tableViewControllerSubclass!.cellIdentifier(tableView: tableView, indexPath: indexPath)
        if sizingCells[cellIdentifier] == nil { sizingCells[cellIdentifier] = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier) }
        if sizingCells[cellIdentifier] == nil { log(owner:"SATableViewController", value: "No cell for identifier \"\(cellIdentifier)\"", level: .Error) }
        let cell = (forSizing ? sizingCells[cellIdentifier]! : self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath))
        /*if tableView == searchDisplayController?.searchResultsTableView {
        if searchObjects?.count > indexPath.row {
        (self as StartWebListViewControllerSubclass).formatCell(cell, object: searchObjects![indexPath.row])
        }
        } else {*/
        if let object: Any = object(tableView: tableView, indexPath: indexPath) {
            tableViewControllerSubclass?.formatCell(tableView: tableView, cell: cell, object: object, indexPath: indexPath)
        }
        //}
        return cell
}
/*

    /*public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    //if tableView == searchDisplayController?.searchResultsTableView { return }
    if let loadingStatus = tableViewControllerSubclass?.loadingStatus(tableView: tableView, section: indexPath.section) where !loadingStatus.hasData() {
    return
    }
    /*if indexPath.section == pagingSection {
    loadDataPaging(nextPage: true)
    }*/
    }*/
*/*/

    /********************************************************************************************************/
    // MARK: TableView Selection Methods
    /********************************************************************************************************/
    
    var autoDeselectRow = true
    
    public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*if tableView == searchDisplayController?.searchResultsTableView {
        (self as StartWebListViewControllerSubclass).selectedRow(object: searchObjects![indexPath.row])
        return
        }*/
        guard let object = object(tableView: tableView, indexPath: indexPath) else { return false }
        return tableViewControllerSubclass.shouldHighlightObject(tableView: tableView, object: object, indexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if autoDeselectRow { tableView.deselectRowAtIndexPath(indexPath, animated: true) }
        /*if tableView == searchDisplayController?.searchResultsTableView {
        (self as StartWebListViewControllerSubclass).selectedRow(object: searchObjects![indexPath.row])
        return
        }*/
        guard let object = object(tableView: tableView, indexPath: indexPath) else { return }
        tableViewControllerSubclass.didSelectObject(tableView: tableView, object: object, indexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        guard let object = object(tableView: tableView, indexPath: indexPath) else { return }
        tableViewControllerSubclass.didDeselectObject(tableView: tableView, object: object, indexPath: indexPath)
    }

    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        /*if tableView == searchDisplayController?.searchResultsTableView {
        (self as StartWebListViewControllerSubclass).selectedRow(object: searchObjects![indexPath.row])
        return
        }*/
        guard let object = object(tableView: tableView, indexPath: indexPath) else { return }
        tableViewControllerSubclass.didSelectObjectAccessory(tableView: tableView, object: object, indexPath: indexPath)
    }
    
    func shouldHighlightObject(tableView tableView: UITableView, object: Any, indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func didDeselectObject(tableView tableView: UITableView, object: Any, indexPath: NSIndexPath) {
        // Subclass
    }
    
    func didSelectObjectAccessory(tableView tableView: UITableView, object: Any, indexPath: NSIndexPath) {
        tableViewControllerSubclass.didSelectObject(tableView: tableView, object: object, indexPath: indexPath)
    }
    
}*/