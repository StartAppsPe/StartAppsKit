//
//  LoadActionViewDelegates.swift
//  Pods
//
//  Created by Gabriel Lanata on 11/30/15.
//
//

import UIKit

extension UIActivityIndicatorView: LoadActionDelegate {
    
    public func loadActionUpdated<L: LoadActionType>(loadAction: L, updatedProperties: Set<LoadActionProperties>) {
        guard updatedProperties.contains(.status) else { return }
        switch loadAction.status {
        case .loading: self.startAnimating()
        case .ready:   self.stopAnimating()
        }
    }
    
}

extension UIButton: LoadActionDelegate {
    
    public func loadActionUpdated<L: LoadActionType>(loadAction: L, updatedProperties: Set<LoadActionProperties>) {
        guard updatedProperties.contains(.status) || updatedProperties.contains(.error) else { return }
        switch loadAction.status {
        case .loading:
            activityIndicatorView?.startAnimating()
            isUserInteractionEnabled = false
            tempTitle = ""
        case .ready:
            activityIndicatorView?.stopAnimating()
            activityIndicatorView  = nil
            isUserInteractionEnabled = true
            if loadAction.error != nil {
                tempTitle = errorTitle ?? "Error"
            } else {
                tempTitle = nil
            }
        }
    }
    
}

extension UIRefreshControl: LoadActionDelegate {
    
    public func loadActionUpdated<L: LoadActionType>(loadAction: L, updatedProperties: Set<LoadActionProperties>) {
        guard updatedProperties.contains(.status) else { return }
        switch loadAction.status {
        case .loading: active = true
        case .ready:   active = false
        }
    }
    
    public convenience init(loadAction: LoadActionLoadableType) {
        self.init()
        setAction(loadAction: loadAction)
        loadAction.addDelegate(self)
    }
    
    public func setAction(loadAction: LoadActionLoadableType) {
        setAction(controlEvents: .valueChanged, loadAction: loadAction)
    }
    
}

extension UIControl {
    
    public func setAction(controlEvents: UIControlEvents, loadAction: LoadActionLoadableType) {
        setAction(controlEvents: controlEvents) { (sender) in
            loadAction.loadNew()
        }
    }
    
}


open class LoadActionStatusViewParams {
    open var activityAnimating: Bool
    open var image: UIImage?
    open var message: String?
    open var buttonTitle: String?
    open var buttonColor: UIColor?
    open var buttonAction: ((_ sender: AnyObject) -> Void)?
    public init(activityAnimating: Bool = false, image: UIImage? = nil, message: String? = nil,
        buttonTitle: String? = nil, buttonColor: UIColor? = nil, buttonAction: ((_ sender: AnyObject) -> Void)? = nil) {
            self.activityAnimating = activityAnimating
            self.image = image
            self.message = message
            self.buttonTitle = buttonTitle
            self.buttonColor = buttonColor
            self.buttonAction = buttonAction
    }
    
    public struct LoadActionStatusViewParamsDefault {
        public var loadingParams: LoadActionStatusViewParams { return LoadActionStatusViewParams(activityAnimating: true) }
        public var errorParams:   LoadActionStatusViewParams { return LoadActionStatusViewParams(message: "Error") }
        public var emptyParams:   LoadActionStatusViewParams { return LoadActionStatusViewParams(message: "No data") }
    }
    open static var defaultParams = LoadActionStatusViewParamsDefault()
}

open class LoadActionStatusView: UIView, LoadActionDelegate {
    
    @IBOutlet open weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet open weak var boxView:   UIView!
    @IBOutlet open weak var imageView: UIImageView!
    @IBOutlet open weak var textLabel: UILabel!
    @IBOutlet open weak var button:    UIButton!
    
    @IBOutlet fileprivate weak var buttonHeightConstraint:    NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewAspectConstraint: NSLayoutConstraint!
    
    open var loadingParams = LoadActionStatusViewParams.defaultParams.loadingParams
    open var errorParams   = LoadActionStatusViewParams.defaultParams.errorParams
    open var emptyParams   = LoadActionStatusViewParams.defaultParams.emptyParams
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open class func loadFromNib() -> LoadActionStatusView {
        let rootBundle = Bundle(for: LoadActionStatusView.self)
        let bundleURL = rootBundle.url(forResource: "StartAppsKit", withExtension: "bundle")!
        let cellNib = UINib(nibName: "LoadActionStatusView", bundle: Bundle(url: bundleURL))
        let instant = cellNib.instantiate(withOwner: self, options: nil)
        let loadingStatusView = instant.first! as? LoadActionStatusView
        return loadingStatusView!
    }

    open func loadActionUpdated<L: LoadActionType>(loadAction: L, updatedProperties: Set<LoadActionProperties>) {
        var params: LoadActionStatusViewParams?
        if let value = loadAction.valueAny , (value as? NSArray)?.count ?? 1 > 0  {
            // No params
        } else if loadAction.status == .loading {
            params = loadingParams
        } else if loadAction.error != nil {
            params = errorParams
        } else {
            params = emptyParams
        }
        
        isHidden = (params == nil)
        button.title = params?.buttonTitle
        button.backgroundColor = params?.buttonColor ?? UIColor.gray
        textLabel.text = params?.message
        imageView.image = params?.image
        activityIndicatorView.active = params?.activityAnimating ?? false
        
        button.isHidden = (button.title?.clean() == nil)
        button.title  = (button.title?.clean() != nil ? "   \(button.title!)   " : nil)
        button.isUserInteractionEnabled   = (button.title?.clean() != nil)
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
    
    fileprivate func createLoadActionStatusView() -> LoadActionStatusView {
        let tempView = LoadActionStatusView.loadFromNib()
        tempView.backgroundColor = UIColor.clear
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
    
    public var refreshControlCompat: UIRefreshControl? {
        get {
            if #available(iOS 10.0, *) {
                return refreshControl
            } else {
                return objc_getAssociatedObject(self, &_rcak) as? UIRefreshControl
            }
        }
        set {
            if #available(iOS 10.0, *) {
                refreshControl = newValue
            } else {
                objc_setAssociatedObject(self, &_rcak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
            if let newValue = newValue {
                alwaysBounceVertical = true
                addSubview(newValue)
            }
        }
    }
    
}

extension UIScrollView: LoadActionDelegate {
    
    public func loadActionUpdated<L: LoadActionType>(loadAction: L, updatedProperties: Set<LoadActionProperties>) {
        if #available(iOS 10.0, *) {
            refreshControl?.loadActionUpdated(loadAction: loadAction, updatedProperties: updatedProperties)
        } else {
            refreshControlCompat?.loadActionUpdated(loadAction: loadAction, updatedProperties: updatedProperties)
        }

        if let tableView = self as? UITableView {
            tableView.loadActionStatusView.loadActionUpdated(loadAction: loadAction, updatedProperties: updatedProperties)
            tableView.separatorStyle = (loadAction.value != nil ? .singleLine : .none)
            tableView.reloadData()
        }
        if let collectionView = self as? UICollectionView {
            collectionView.loadActionStatusView.loadActionUpdated(loadAction: loadAction, updatedProperties: updatedProperties)
            collectionView.reloadData()
        }
    }
    
}

