//
//  SACollectionViewController.swift
//  Pods
//
//  Created by Gabriel Lanata on 24/2/16.
//
//

/*import UIKit

public protocol SACollectionViewControllerSubclass: SAViewControllerSubclass {
    
    /*OPTIONAL*/ var collectionViewControllerSubclass: SACollectionViewControllerSubclass! { get }
    
    /*OPTIONAL*/ var collectionView: UICollectionView! { get }
    /*OPTIONAL*/ var refreshControl: UIRefreshControl? { get }
    
    /*OPTIONAL*/ var headerView: UIView? { get }
    /*OPTIONAL*/ var headerViewHeightLayoutConstraint: NSLayoutConstraint? { get }
    /*OPTIONAL*/ var headerViewDefaultHeight: CGFloat? { get }
    
    /*REQUIRED*/ //func loadingStatus(collectionView collectionView: UICollectionView, section: Int?) -> LoadingStatus
    /*REQUIRED*/ //func loadingStatusInfoGroup(collectionView collectionView: UICollectionView, section: Int?) -> LoadingStatusInfoGroup
    
    /*REQUIRED*/ func objects(collectionView collectionView: UICollectionView) -> [Any]?
    /*OPTIONAL*/ func object(collectionView collectionView: UICollectionView, indexPath: NSIndexPath) -> Any?
    
    /*REQUIRED*/ func cellIdentifier(collectionView collectionView: UICollectionView, object: Any, indexPath: NSIndexPath) -> String
    /*REQUIRED*/ func formattedCell(collectionView collectionView: UICollectionView, cell: UICollectionViewCell, object: Any, indexPath: NSIndexPath) -> UICollectionViewCell
    
    /*OPTIONAL*/ func heightForObject(collectionView collectionView: UICollectionView, object: Any, indexPath: NSIndexPath) -> CGFloat?
    /*OPTIONAL*/ func heightEstimateForObject(collectionView collectionView: UICollectionView, object: Any, indexPath: NSIndexPath) -> CGFloat?
    
    /*OPTIONAL*/ func shouldHighlightObject(collectionView collectionView: UICollectionView, object: Any, indexPath: NSIndexPath) -> Bool
    /*REQUIRED*/ func didSelectObject(collectionView collectionView: UICollectionView, object: Any, indexPath: NSIndexPath)
    /*OPTIONAL*/ func didDeselectObject(collectionView collectionView: UICollectionView, object: Any, indexPath: NSIndexPath)
    /*OPTIONAL*/ func didSelectObjectAccessory(collectionView collectionView: UICollectionView, object: Any, indexPath: NSIndexPath)
}

public protocol SASectionedCollectionViewControllerSubclass: SACollectionViewControllerSubclass {
    
    /*OPTIONAL*/ var sectionedCollectionViewControllerSubclass: SASectionedCollectionViewControllerSubclass? { get }
    
    /*OPTIONAL*/ func objects(collectionView collectionView: UICollectionView, section: Int) -> [Any]?
    
    /*REQUIRED*/ func sectionTitle(collectionView collectionView: UICollectionView, section: Int) -> String?
    
}

public protocol SASearchableCollectionViewControllerSubclass: SACollectionViewControllerSubclass {
    
    /*OPTIONAL*/ var searchableCollectionViewControllerSubclass: SASearchableCollectionViewControllerSubclass? { get }
    
    /*REQUIRED*/ func cellIdentifierForSearch(collectionView collectionView: UICollectionView, object: Any, indexPath: NSIndexPath) -> String
    
    /*REQUIRED*/ //func objectsForSearch(collectionView collectionView: UICollectionView, searchString: String, result: LoadObjectsResult)
    /*REQUIRED*/ //func objectsForCacheSearch(collectionView collectionView: UICollectionView, searchString: String, result: LoadObjectsResult)
    
}

public class SACollectionViewController: SAViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet public weak var collectionView: UICollectionView!
    public var refreshControl: UIRefreshControl?
    
    @IBOutlet public weak var headerView: UIView?
    @IBOutlet public weak var headerViewHeightLayoutConstraint: NSLayoutConstraint?
    public var headerViewDefaultHeight: CGFloat?
    
    public var collectionViewControllerSubclass:           SACollectionViewControllerSubclass!
    public var sectionedCollectionViewControllerSubclass:  SASectionedCollectionViewControllerSubclass?
    public var searchableCollectionViewControllerSubclass: SASearchableCollectionViewControllerSubclass?
    
    /********************************************************************************************************/
     // MARK: View Management Methods
     /********************************************************************************************************/
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set subclasses
        collectionViewControllerSubclass           = self as! SACollectionViewControllerSubclass
        sectionedCollectionViewControllerSubclass  = self as? SASectionedCollectionViewControllerSubclass
        searchableCollectionViewControllerSubclass = self as? SASearchableCollectionViewControllerSubclass
        
        // Set self as DataSource and Delegate
        collectionView.dataSource = self
        collectionView.delegate   = self
        
        // Setup refresh controller
        if let _ = collectionViewControllerSubclass?.loadAction() {
            refreshControl = UIRefreshControl()
            refreshControl!.addTarget(self, action: "loadDataNew", forControlEvents: .ValueChanged)
            collectionView.addSubview(refreshControl!)
        }
        
        // Setup header stretch default height
        headerViewDefaultHeight = headerViewHeightLayoutConstraint?.constant
        
        // Register InfoCell Nib
        //let nib = UINib(nibName: "SAInfoCollectionViewCell", bundle: nil)
        //collectionView.registerNib(nib, forCellReuseIdentifier: "InfoCell")
        
    }
    
    /********************************************************************************************************/
     // MARK: Loading Data Methods
     /********************************************************************************************************/
    
    public override func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updatedProperties: Set<LoadActionProperties>) {
        switch loadAction.status {
        case .Loading, .Paging:
            // Do not stop refreshControl if started
            // Disabled because it causes gitter
            // TODO: Confirm behavious of this
            refreshControl?.beginRefreshing()
        case .Ready:
            refreshControl?.endRefreshing()
        }
        super.loadActionUpdated(loadAction: loadAction, updatedProperties: updatedProperties)
        collectionView?.reloadData()
    }
    
    /********************************************************************************************************/
     // MARK: CollectionView Loading Status Methods
     /********************************************************************************************************/
     
     /*public func infoCollectionViewCellLoadingButtonPressed() {
     // Do nothing, subclass
     }
     
     public func infoCollectionViewCellEmptyButtonPressed() {
     newObject()
     }
     
     public func infoCollectionViewCellErrorButtonPressed() {
     loadData(forced: true)
     }*/
     
     /********************************************************************************************************/
     // MARK: CollectionView Header Methods
     /********************************************************************************************************/
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            if let headerViewHeightLayoutConstraint = headerViewHeightLayoutConstraint {
                headerViewHeightLayoutConstraint.constant = (headerViewDefaultHeight ?? 0)-scrollView.contentOffset.y
            }
        }
    }
    
    /********************************************************************************************************/
     // MARK: CollectionView Section Methods
     /********************************************************************************************************/
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //if collectionView == searchDisplayController?.searchResultsCollectionView { return 1 }
        guard let objects = sectionedCollectionViewControllerSubclass?.objects(collectionView: collectionView) as? [[Any]] else { return 1 }
        return objects.count
    }
    
//    public func collectionView(collectionView: UICollectionView, titleForHeaderInSection section: Int) -> String? {
//        //if collectionView == searchDisplayController?.searchResultsCollectionView { return nil }
//        guard objects(collectionView: collectionView, section: section)?.count ?? 0 > 0 else { return nil }
//        return sectionedCollectionViewControllerSubclass?.sectionTitle(collectionView: collectionView, section: section)
//    }
//    
//    public func collectionView(collectionView: UICollectionView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        if let header = view as? UICollectionViewHeaderFooterView {
//            header.textLabel!.font = UIFont.boldSystemFontOfSize(15)
//            header.textLabel!.textAlignment = .Center
//            header.textLabel!.frame = header.frame
//        }
//    }
    
    /********************************************************************************************************/
     // MARK: CollectionView Item Methods
     /********************************************************************************************************/
    
    public func objects(collectionView collectionView: UICollectionView, section: Int) -> [Any]? {
        if let subclass = sectionedCollectionViewControllerSubclass {
            return subclass.objects(collectionView: collectionView)?[section] as? [Any]
        } else if let subclass = collectionViewControllerSubclass {
            return subclass.objects(collectionView: collectionView)
        }
        return nil
    }
    
    public func object(collectionView collectionView: UICollectionView, indexPath: NSIndexPath) -> Any? {
        return objects(collectionView: collectionView, section: indexPath.section)?[indexPath.item]
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if collectionView == searchDisplayController?.searchResultsCollectionView { return searchObjects?.count ?? 0 }
        return min(objects(collectionView: collectionView, section: section)?.count ?? 0, 1)
    }
    /*
    
    let HeightForItemAutomaticFillTable: CGFloat = -123456
    func heightForItem(collectionView collectionView: UICollectionView, object: Any, indexPath: NSIndexPath) -> CGFloat? {
    return nil
    }
    
    public func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //if UIDevice.currentDevice().systemVersion.compare("8.0", options: .NumericSearch) != .OrderedAscending { //Solo en > iOS 8
    //    return UICollectionViewAutomaticDimension;
    //}
    
    /*if collectionView == searchDisplayController?.searchResultsCollectionView {
    return formattedCell(collectionView: collectionView, indexPath: indexPath, forSizing: true).autoLayoutHeight()
    }*/
    if let loadingStatus = collectionViewControllerSubclass?.loadingStatus(collectionView: collectionView, section: indexPath.section) where !loadingStatus.hasData() {
    let collectionViewHeight = collectionView.frame.size.height-(collectionView.tableHeaderView?.frame.size.height ?? 0)-(collectionView.tableFooterView?.frame.size.height ?? 0)
    return collectionViewHeight
    }
    //if indexPath.section == pagingSection { return 50 }
    let autoHeightForItem = formattedCell(collectionView: collectionView, indexPath: indexPath, forSizing: true).autoLayoutHeight(collectionView)
    if let object: Any = object(collectionView: collectionView, indexPath: indexPath) {
    if let strictHeightForItem = heightForItem(collectionView: collectionView, object: object, indexPath: indexPath) {
    if strictHeightForItem == HeightForItemAutomaticFillTable {
    let collectionViewHeight = collectionView.frame.size.height-(collectionView.tableHeaderView?.frame.size.height ?? 0)-(collectionView.tableFooterView?.frame.size.height ?? 0)
    let itemCount = CGFloat(self.collectionView(collectionView, numberOfItemsInSection: indexPath.section))
    let itemHeight = ceil(collectionViewHeight/itemCount)
    return min(max(itemHeight, autoHeightForItem), 100)
    }
    return strictHeightForItem
    }
    }
    return autoHeightForItem
    }
    */
    
    
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        /*if collectionView == searchDisplayController?.searchResultsCollectionView {
        return formattedCell(collectionView: collectionView, indexPath: indexPath)
        }*/
        guard let object = object(collectionView: collectionView, indexPath: indexPath) else {
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("InfoCell", forIndexPath: indexPath) //as! InfoCollectionViewCell
            //cell.loadingStatusInfoGroup = collectionViewControllerSubclass!.loadingStatusInfoGroup(collectionView: collectionView, section: indexPath.section)
            //cell.loadingStatus = loadingStatus
            //cell.delegate = self
            // TODO: Do this
            return cell
        }
        let cellIdentifier = collectionViewControllerSubclass.cellIdentifier(collectionView: collectionView, object: object, indexPath: indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath)
        return collectionViewControllerSubclass.formattedCell(collectionView: collectionView, cell: cell, object: object, indexPath: indexPath)
    }
    /*
    
    var sizingCells = [String : UICollectionViewCell]()
    public func formattedCell(collectionView collectionView: UICollectionView, indexPath: NSIndexPath, forSizing: Bool = false) -> UICollectionViewCell {
    let cellIdentifier = collectionViewControllerSubclass!.cellIdentifier(collectionView: collectionView, indexPath: indexPath)
    if sizingCells[cellIdentifier] == nil { sizingCells[cellIdentifier] = self.collectionView.dequeueReusableCellWithIdentifier(cellIdentifier) }
    if sizingCells[cellIdentifier] == nil { log(owner:"SACollectionViewController", value: "No cell for identifier \"\(cellIdentifier)\"", level: .Error) }
    let cell = (forSizing ? sizingCells[cellIdentifier]! : self.collectionView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath))
    /*if collectionView == searchDisplayController?.searchResultsCollectionView {
    if searchObjects?.count > indexPath.item {
    (self as StartWebListViewControllerSubclass).formatCell(cell, object: searchObjects![indexPath.item])
    }
    } else {*/
    if let object: Any = object(collectionView: collectionView, indexPath: indexPath) {
    collectionViewControllerSubclass?.formatCell(collectionView: collectionView, cell: cell, object: object, indexPath: indexPath)
    }
    //}
    return cell
    }*/
    
    /********************************************************************************************************/
    // MARK: CollectionView Selection Methods
    /********************************************************************************************************/
    
    
    public func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*if collectionView == searchDisplayController?.searchResultsCollectionView {
        (self as StartWebListViewControllerSubclass).selectedItem(object: searchObjects![indexPath.item])
        return
        }*/
        guard let object = object(collectionView: collectionView, indexPath: indexPath) else { return false }
        return collectionViewControllerSubclass.shouldHighlightObject(collectionView: collectionView, object: object, indexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        /*if collectionView == searchDisplayController?.searchResultsCollectionView {
        (self as StartWebListViewControllerSubclass).selectedItem(object: searchObjects![indexPath.item])
        return
        }*/
        guard let object = object(collectionView: collectionView, indexPath: indexPath) else { return }
        collectionViewControllerSubclass.didSelectObject(collectionView: collectionView, object: object, indexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        guard let object = object(collectionView: collectionView, indexPath: indexPath) else { return }
        collectionViewControllerSubclass.didDeselectObject(collectionView: collectionView, object: object, indexPath: indexPath)
    }
    
    func shouldHighlightObject(collectionView collectionView: UICollectionView, object: Any, indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func didDeselectObject(collectionView collectionView: UICollectionView, object: Any, indexPath: NSIndexPath) {
        // Subclass
    }
    
}*/