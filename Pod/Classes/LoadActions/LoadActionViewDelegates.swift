//
//  LoadActionViewDelegates.swift
//  Pods
//
//  Created by Gabriel Lanata on 11/30/15.
//
//

import UIKit

extension UIActivityIndicatorView: LoadActionDelegate {
    
    public func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updatedProperties: Set<LoadActionProperties>) {
        guard updatedProperties.contains(.Status) else { return }
        switch loadAction.status {
        case .Loading: self.startAnimating()
        case .Ready:   self.stopAnimating()
        }
    }
    
}

extension UIButton: LoadActionDelegate {
    
    public func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updatedProperties: Set<LoadActionProperties>) {
        guard updatedProperties.contains(.Status) || updatedProperties.contains(.Error) else { return }
        switch loadAction.status {
        case .Loading:
            activityIndicatorView?.startAnimating()
            userInteractionEnabled = false
            tempTitle = ""
        case .Ready:
            activityIndicatorView?.stopAnimating()
            activityIndicatorView  = nil
            userInteractionEnabled = true
            if loadAction.error != nil {
                tempTitle = errorTitle ?? "Error"
            } else {
                tempTitle = nil
            }
        }
    }
    
}

extension UIRefreshControl: LoadActionDelegate {
    
    public func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updatedProperties: Set<LoadActionProperties>) {
        guard updatedProperties.contains(.Status) else { return }
        switch loadAction.status {
        case .Loading: animating = true
        case .Ready:   animating = false
        }
    }
    
    public convenience init(loadAction: LoadActionLoadableType) {
        self.init()
        setAction(loadAction: loadAction)
        loadAction.addDelegate(self)
    }
    
    public func setAction(loadAction loadAction: LoadActionLoadableType) {
        setAction(controlEvents: .ValueChanged, loadAction: loadAction)
    }
    
}

extension UIControl {
    
    public func setAction(controlEvents controlEvents: UIControlEvents, loadAction: LoadActionLoadableType) {
        setAction(controlEvents: controlEvents) { (sender) in
            loadAction.loadNew()
        }
    }
    
}


public struct LoadActionStatusViewParams {
    public var activityAnimating: Bool
    public var image: UIImage?
    public var message: String?
    public var buttonTitle: String?
    public var buttonColor: UIColor?
    public var buttonAction: ((sender: AnyObject) -> Void)?
    public init(activityAnimating: Bool = false, image: UIImage? = nil, message: String? = nil,
        buttonTitle: String? = nil, buttonColor: UIColor? = nil, buttonAction: ((sender: AnyObject) -> Void)? = nil) {
            self.activityAnimating = activityAnimating
            self.image = image
            self.message = message
            self.buttonTitle = buttonTitle
            self.buttonColor = buttonColor
            self.buttonAction = buttonAction
    }
    
    public struct LoadActionStatusViewParamsDefault {
        public var loadingParams = LoadActionStatusViewParams(activityAnimating: true)
        public var errorParams   = LoadActionStatusViewParams(message: "Error")
        public var emptyParams   = LoadActionStatusViewParams(message: "No data")
    }
    public static var defaultParams = LoadActionStatusViewParamsDefault()
}

public class LoadActionStatusView: UIView, LoadActionDelegate {
    
    @IBOutlet public weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet public weak var boxView:   UIView!
    @IBOutlet public weak var imageView: UIImageView!
    @IBOutlet public weak var textLabel: UILabel!
    @IBOutlet public weak var button:    UIButton!
    
    @IBOutlet private weak var buttonHeightConstraint:    NSLayoutConstraint!
    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewAspectConstraint: NSLayoutConstraint!
    
    public var loadingParams = LoadActionStatusViewParams.defaultParams.loadingParams
    public var errorParams   = LoadActionStatusViewParams.defaultParams.errorParams
    public var emptyParams   = LoadActionStatusViewParams.defaultParams.emptyParams
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public class func loadFromNib() -> LoadActionStatusView {
        let rootBundle = NSBundle(forClass: LoadActionStatusView.self)
        let bundleURL = rootBundle.URLForResource("StartAppsKit", withExtension: "bundle")!
        let cellNib = UINib(nibName: "LoadActionStatusView", bundle: NSBundle(URL: bundleURL))
        let instant = cellNib.instantiateWithOwner(self, options: nil)
        let loadingStatusView = instant.first! as? LoadActionStatusView
        return loadingStatusView!
    }

    public func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updatedProperties: Set<LoadActionProperties>) {
        var params: LoadActionStatusViewParams?
        if let value = loadAction.valueAny where (value as? NSArray)?.count ?? 1 > 0  {
            // No params
        } else if loadAction.status == .Loading {
            params = loadingParams
        } else if loadAction.error != nil {
            params = errorParams
        } else {
            params = emptyParams
        }
        
        hidden = (params == nil)
        button.title = params?.buttonTitle
        button.backgroundColor = params?.buttonColor ?? UIColor.grayColor()
        textLabel.text = params?.message
        imageView.image = params?.image
        activityIndicatorView.animating = params?.activityAnimating ?? false
        
        button.hidden = (button.title?.clean() == nil)
        button.title  = (button.title?.clean() != nil ? "   \(button.title!)   " : nil)
        button.userInteractionEnabled   = (button.title?.clean() != nil)
        buttonHeightConstraint.constant = (button.title?.clean() != nil ? 40 : 0)
        let imageSize = imageView.image?.size
        imageViewAspectConstraint.constant = (imageSize?.width ?? 1)/(imageSize?.height ?? 1)
        imageViewHeightConstraint.constant = imageSize?.height ?? 0
    }
    
}


private var _svak: UInt8 = 0
private var _rcak: UInt8 = 1

public protocol StatusViewPresentable: class {
    var backgroundView: UIView? { set get }
}

public extension StatusViewPresentable {
    
    private func createLoadActionStatusView() -> LoadActionStatusView {
        let tempView = LoadActionStatusView.loadFromNib()
        tempView.backgroundColor = UIColor.clearColor()
        backgroundView = tempView
        return tempView
    }
    
    public var loadActionStatusView: LoadActionStatusView {
        get { return objc_getAssociatedObject(self, &_svak) as? LoadActionStatusView ?? createLoadActionStatusView() }
        set { objc_setAssociatedObject(self, &_svak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
    }
    
}

extension UICollectionView: StatusViewPresentable { }
extension UITableView: StatusViewPresentable { }

public extension UIScrollView {
    
    public var refreshControl: UIRefreshControl? {
        get { return objc_getAssociatedObject(self, &_rcak) as? UIRefreshControl }
        set {
            objc_setAssociatedObject(self, &_rcak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            if let newValue = newValue {
                alwaysBounceVertical = true
                addSubview(newValue)
            }
        }
    }
    
}

extension UIScrollView: LoadActionDelegate {
    
    public func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updatedProperties: Set<LoadActionProperties>) {
        refreshControl?.loadActionUpdated(loadAction: loadAction, updatedProperties: updatedProperties)
        if let tableView = self as? UITableView {
            tableView.loadActionStatusView.loadActionUpdated(loadAction: loadAction, updatedProperties: updatedProperties)
            tableView.separatorStyle = (loadAction.value != nil ? .SingleLine : .None)
            tableView.reloadData()
        }
        if let collectionView = self as? UICollectionView {
            collectionView.loadActionStatusView.loadActionUpdated(loadAction: loadAction, updatedProperties: updatedProperties)
            collectionView.reloadData()
        }
    }
    
}

