//
//  SATableViewController.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 3/2/15.
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
    /*REQUIRED*/ func loadingStatusInfoGroup(tableView tableView: UITableView, section: Int?) -> LoadingStatusInfoGroup
    
    /*REQUIRED*/ func objects(tableView tableView: UITableView) -> [AnyObject]?
    /*OPTIONAL*/ func object(tableView tableView: UITableView, indexPath: NSIndexPath) -> AnyObject?
    
    /*REQUIRED*/ func cellIdentifier(tableView tableView: UITableView, indexPath: NSIndexPath) -> String
    
    /*REQUIRED*/ func formatCell(tableView tableView: UITableView, cell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath)
    
    /*OPTIONAL*/ func heightForRow(tableView tableView: UITableView, object: AnyObject, indexPath: NSIndexPath) -> CGFloat?
    
    /*OPTIONAL*/ func shouldHighlightRow(tableView tableView: UITableView, object: AnyObject, indexPath: NSIndexPath) -> Bool
    /*REQUIRED*/ func selectedRow(tableView tableView: UITableView, object: AnyObject, indexPath: NSIndexPath)
    /*OPTIONAL*/ func selectedRowAccessory(tableView tableView: UITableView, object: AnyObject, indexPath: NSIndexPath)
    /*OPTIONAL*/ func deselectedRow(tableView tableView: UITableView, object: AnyObject, indexPath: NSIndexPath)
    
}

public protocol SASectionedTableViewControllerSubclass: SATableViewControllerSubclass {
    
    /*OPTIONAL*/ var sectionedTableViewControllerSubclass: SASectionedTableViewControllerSubclass? { get }
    
    /*OPTIONAL*/ func objects(tableView tableView: UITableView, section: Int) -> [AnyObject]?
    
    /*REQUIRED*/ func headerForSection(tableView tableView: UITableView, section: Int) -> String?
    
}

public protocol SASearchableTableViewControllerSubclass: SATableViewControllerSubclass {
    
    /*OPTIONAL*/ var searchableTableViewControllerSubclass: SASearchableTableViewControllerSubclass? { get }
    
    /*REQUIRED*/ func cellIdentifierForSearch(tableView tableView: UITableView) -> String?
    
    /*REQUIRED*/ func performCacheSearch(searchString: String, result: LoadObjectsResult)
    /*REQUIRED*/ func performWebSearch(searchString: String, result: LoadObjectsResult)
    
}

public class SATableViewController: SAViewController, UITableViewDataSource, UITableViewDelegate, InfoTableViewCellDelegate {
    
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
        
        // Set subclasses
        tableViewControllerSubclass           = self as? SATableViewControllerSubclass
        sectionedTableViewControllerSubclass  = self as? SASectionedTableViewControllerSubclass
        searchableTableViewControllerSubclass = self as? SASearchableTableViewControllerSubclass
        
        // Call super
        super.viewDidLoad()
    }
    
    public override func innerSetupView() {
        super.innerSetupView()
        
        // Set self as DataSource and Delegate
        tableView.dataSource = self
        tableView.delegate   = self
        
        // Setup Refresh Controller
        if let loadActions = tableViewControllerSubclass?.loadActions where loadActions.actions.count > 0 {
            refreshControl = UIRefreshControl()
            refreshControl!.addTarget(self, action: "loadDataNew", forControlEvents: .ValueChanged)
            tableView.addSubview(refreshControl!)
        }
        
        // Setup Header Stretch
        headerViewDefaultHeight = headerViewHeightLayoutConstraint?.constant
        
        // Scroll for Search Bar
        if let _ = searchDisplayController {
            tableView.contentOffset = CGPoint(x: 0, y: 44)
        }
        
        // Setup Search Controller Backup Cell
        if let cellIdentifier = searchableTableViewControllerSubclass?.cellIdentifierForSearch(tableView: tableView) {
            searchDisplayController?.searchResultsTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
        }
        
        // Register InfoCell Nib
        let nib = UINib(nibName: "SAInfoTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "InfoCell")
        
    }
    
    /********************************************************************************************************/
    // MARK: Loading Data Methods
    /********************************************************************************************************/
    
    public override func loadActionsUpdated() {
        switch loadActions.loadingStatus {
        case .Loading, .Reloading, .Paging: ()
            // Do not stop refreshControl if started
            // Disabled because it causes gitter
            // refreshControl?.beginRefreshing()
        default:
            refreshControl?.endRefreshing()
        }
        super.loadActionsUpdated()
        tableView?.reloadData()
    }
    
    /********************************************************************************************************/
    // MARK: TableView Loading Status Methods
    /********************************************************************************************************/
    
    public func infoTableViewCellLoadingButtonPressed() {
        // Do nothing, subclass
    }
    
    public func infoTableViewCellEmptyButtonPressed() {
        newObject()
    }
    
    public func infoTableViewCellErrorButtonPressed() {
        loadData(forced: true)
    }
    
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
        if let objects = sectionedTableViewControllerSubclass?.objects(tableView: tableView) {
            if let _ = objects.first as? [AnyObject] {
                return objects.count//+(pagingHasMore ? 1 : 0)
            }
            return 1//+(pagingHasMore ? 1 : 0)
        } else if let _ = tableViewControllerSubclass {
            return 1//+(pagingHasMore ? 1 : 0)
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //if tableView == searchDisplayController?.searchResultsTableView { return nil }
        if let loadingStatus = sectionedTableViewControllerSubclass?.loadingStatus(tableView: tableView, section: section) where !loadingStatus.hasData() {
            return nil
        }
        //if section == pagingSection { return nil }
        if let objects = sectionedTableViewControllerSubclass?.objects(tableView: tableView, section: section) {
            if objects.count == 0 { return nil }
        }
        return sectionedTableViewControllerSubclass?.headerForSection(tableView: tableView, section: section)
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
    
    public func objects(tableView tableView: UITableView, section: Int) -> [AnyObject]? {
        if let objects = tableViewControllerSubclass?.objects(tableView: tableView) {
            return objects[section] as? [AnyObject]
        }
        return nil
    }
    
    public func object(tableView tableView: UITableView, indexPath: NSIndexPath) -> AnyObject? {
        if let objects = sectionedTableViewControllerSubclass?.objects(tableView: tableView, section: indexPath.section) {
            return objects[indexPath.row]
        } else if let objects = tableViewControllerSubclass?.objects(tableView: tableView) {
            return objects[indexPath.row]
        }
        return nil
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if tableView == searchDisplayController?.searchResultsTableView { return searchObjects?.count ?? 0 }
        if let loadingStatus = tableViewControllerSubclass?.loadingStatus(tableView: tableView, section: section) where !loadingStatus.hasData() {
            return 1
        }
        //if section == pagingSection { return 1 }
        if let objects = sectionedTableViewControllerSubclass?.objects(tableView: tableView, section: section) {
            return objects.count
        } else if let objects = tableViewControllerSubclass?.objects(tableView: tableView) {
            return objects.count
        }
        return 0
        //return tableViewControllerSubclass?.objectsForTableView(tableView: tableView)[section].count ?? 0
        //return (self as? SATableViewControllerSubclass)?.numberOfRows?(tableView: tableView, section: section) ?? 0
    }
    
    let HeightForRowAutomaticFillTable: CGFloat = -123456
    func heightForRow(tableView tableView: UITableView, object: AnyObject, indexPath: NSIndexPath) -> CGFloat? {
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
        if let object: AnyObject = object(tableView: tableView, indexPath: indexPath) {
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
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /*if tableView == searchDisplayController?.searchResultsTableView {
        return formattedCell(tableView: tableView, indexPath: indexPath)
        }*/
        if let loadingStatus = tableViewControllerSubclass?.loadingStatus(tableView: tableView, section: indexPath.section) where !loadingStatus.hasData() {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("InfoCell") as! InfoTableViewCell
            cell.loadingStatusInfoGroup = tableViewControllerSubclass!.loadingStatusInfoGroup(tableView: tableView, section: indexPath.section)
            cell.loadingStatus = loadingStatus
            cell.delegate = self
            return cell
        }
        /*if indexPath.section == pagingSection {
        var cell = tableView.dequeueReusableCellWithIdentifier("PagingCell") as? PagingTableViewCell
        if cell == nil { cell = PagingTableViewCell(style: .Default, reuseIdentifier: "PagingCell") }
        return cell!
        }*/
        return formattedCell(tableView: tableView, indexPath: indexPath)
    }
    
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
        if let object: AnyObject = object(tableView: tableView, indexPath: indexPath) {
            tableViewControllerSubclass?.formatCell(tableView: tableView, cell: cell, object: object, indexPath: indexPath)
        }
        //}
        return cell
    }
    
    /*public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    //if tableView == searchDisplayController?.searchResultsTableView { return }
    if let loadingStatus = tableViewControllerSubclass?.loadingStatus(tableView: tableView, section: indexPath.section) where !loadingStatus.hasData() {
    return
    }
    /*if indexPath.section == pagingSection {
    loadDataPaging(nextPage: true)
    }*/
    }*/
    
    
    /********************************************************************************************************/
    // MARK: TableView Selection Methods
    /********************************************************************************************************/
    
    var autoDeselectRow = true
    
    public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*if tableView == searchDisplayController?.searchResultsTableView {
        (self as StartWebListViewControllerSubclass).selectedRow(object: searchObjects![indexPath.row])
        return
        }*/
        if let loadingStatus = tableViewControllerSubclass?.loadingStatus(tableView: tableView, section: indexPath.section) where !loadingStatus.hasData() {
            return false
        }
        //if indexPath.section == pagingSection { return }
        if let object: AnyObject = object(tableView: tableView, indexPath: indexPath) {
            return tableViewControllerSubclass.shouldHighlightRow(tableView: tableView, object: object, indexPath: indexPath)
        }
        return false
    }
    
    public func shouldHighlightRow(tableView tableView: UITableView, object: AnyObject, indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if autoDeselectRow { tableView.deselectRowAtIndexPath(indexPath, animated: true) }
        /*if tableView == searchDisplayController?.searchResultsTableView {
        (self as StartWebListViewControllerSubclass).selectedRow(object: searchObjects![indexPath.row])
        return
        }*/
        if let loadingStatus = tableViewControllerSubclass?.loadingStatus(tableView: tableView, section: indexPath.section) where !loadingStatus.hasData() {
            return
        }
        //if indexPath.section == pagingSection { return }
        if let object: AnyObject = object(tableView: tableView, indexPath: indexPath) {
            tableViewControllerSubclass.selectedRow(tableView: tableView, object: object, indexPath: indexPath)
        }
    }
    
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let loadingStatus = tableViewControllerSubclass?.loadingStatus(tableView: tableView, section: indexPath.section) where !loadingStatus.hasData() {
            return
        }
        if let object: AnyObject = object(tableView: tableView, indexPath: indexPath) {
            tableViewControllerSubclass.deselectedRow(tableView: tableView, object: object, indexPath: indexPath)
        }
    }
    
    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        /*if tableView == searchDisplayController?.searchResultsTableView {
        (self as StartWebListViewControllerSubclass).selectedRow(object: searchObjects![indexPath.row])
        return
        }*/
        if let loadingStatus = tableViewControllerSubclass?.loadingStatus(tableView: tableView, section: indexPath.section) where !loadingStatus.hasData() {
            return
        }
        //if indexPath.section == pagingSection { return }
        if let object: AnyObject = object(tableView: tableView, indexPath: indexPath) {
            tableViewControllerSubclass?.selectedRowAccessory(tableView: tableView, object: object, indexPath: indexPath)
        }
    }
    
    public func selectedRowAccessory(tableView tableView: UITableView, object: AnyObject, indexPath: NSIndexPath) {
        tableViewControllerSubclass?.selectedRow(tableView: tableView, object: object, indexPath: indexPath)
    }
    
    public func deselectedRow(tableView tableView: UITableView, object: AnyObject, indexPath: NSIndexPath) {
        // Do nithing
    }
    
}
*/


/*

/********************************************************************************************************/
// MARK: Data Searching Methods
/********************************************************************************************************/

var webSearchTimer: NSTimer?
public func webSearch() {
webSearchTimer?.invalidate()
webSearchTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "webSearchTimerInner", userInfo: nil, repeats: false)
}

func webSearchTimerInner() {
let searchString = self.searchDisplayController!.searchBar.text

// Call subclass to perform search
(self as StartWebListViewControllerSubclass).performWebSearch?(searchString) { (loadedObjects, error) -> () in
if let error = error {
// Do nothing
} else if let loadedObjects = loadedObjects {
self.searchObjects = loadedObjects
} else {
// Do nothing
}
self.searchDisplayController?.searchResultsTableView.reloadData()
}
}

public func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
(self as StartWebListViewControllerSubclass).performCacheSearch!(searchString) { (loadedObjects, error) -> () in
if let error = error {
// Do nothing
} else if let loadedObjects = loadedObjects {
self.searchObjects = loadedObjects
} else {
// Do nothing
}
dispatch_async(dispatch_get_main_queue()) {
(self as StartWebListViewControllerSubclass).updateView?()
self.searchDisplayController?.searchResultsTableView.reloadData()
}
}
}
webSearch()
return false
}
}

*/