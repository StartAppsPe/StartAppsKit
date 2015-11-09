//
//  SAViewController.swift
//  ULima
//
//  Created by Gabriel Lanata on 3/2/15.
//  Copyright (c) 2015 is.oto.pe. All rights reserved.
//

import UIKit

public protocol SAViewControllerSubclass {
    
    /*OPTIONAL*/ var viewControllerSubclass: SAViewControllerSubclass! { get }
    
    /*OPTIONAL*/ var loadActions:           SALoadActions { get }
    /*OPTIONAL*/ var activityIndicatorView: UIActivityIndicatorView? { get }
    /*OPTIONAL*/ var reloadBarButton:       UIBarButtonItem? { get }
    /*OPTIONAL*/ var reloadButton:          UIButton? { get }
    /*OPTIONAL*/ var newBarButton:          UIBarButtonItem? { get }
    /*OPTIONAL*/ var newButton:             UIButton? { get }
    /*OPTIONAL*/ func reloadButtonPressed(sender: AnyObject)
    /*OPTIONAL*/ func innerSetupView()
    
    /*REQUIRED*/ func createLoadActions() -> SALoadActions
    /*REQUIRED*/ func setupView()
    /*REQUIRED*/ func updateView()
    
}

public class SAViewController: UIViewController, SALoadActionsDelegate {
    
    @IBOutlet public var activityIndicatorView: UIActivityIndicatorView?
    
    @IBOutlet public weak var reloadBarButton: UIBarButtonItem?
    @IBOutlet public weak var reloadButton:    UIButton?
    @IBOutlet public weak var newBarButton:    UIBarButtonItem?
    @IBOutlet public weak var newButton:       UIButton?
    
    public var loadActions = SALoadActions()
    
    public var viewControllerSubclass: SAViewControllerSubclass!
    
    public func loadDataNew() {
        loadData(forced: true)
    }
    
    public func loadData(forced forced: Bool) {
        loadActions.load(forced)
    }
    
    public func newObject() {
        // Do nothing, subclass
    }
    
    /********************************************************************************************************/
    // MARK: View Management Methods
    /********************************************************************************************************/
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set subclasses
        viewControllerSubclass = self as? SAViewControllerSubclass
        
        // Perform setup
        loadActions = viewControllerSubclass.createLoadActions()
        loadActions.delegate = self
        
        // Setup view
        viewControllerSubclass.innerSetupView()
        viewControllerSubclass.setupView()
        
        // Update view
        viewControllerSubclass.updateView()
        
        // Load data
        loadData(forced: false)
    }
    
    public func innerSetupView() {
        // Subclass
    }
    
    /********************************************************************************************************/
    // MARK: Loading Data Methods
    /********************************************************************************************************/
    
    public func loadActionsUpdated() {
        log(owner:"SAViewController", value: "LoadActionsUpdated (loadingStatusAll: \(loadActions.loadingStatus.name()))", level: .Info)
        switch loadActions.loadingStatus {
        case .Loading:
            activityIndicatorView?.startAnimating()
        case .Reloading:
            activityIndicatorView?.startAnimating()
        default:
            activityIndicatorView?.stopAnimating()
        }
        viewControllerSubclass.updateView()
    }
    
    @IBAction public func reloadButtonPressed(sender: AnyObject) {
        loadData(forced: true)
    }
    
    @IBAction public func newButtonPressed(sender: AnyObject) {
        newObject()
    }
    
}
