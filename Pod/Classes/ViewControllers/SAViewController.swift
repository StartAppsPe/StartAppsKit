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
    
    /*OPTIONAL*/ var activityIndicatorView: UIActivityIndicatorView? { get }
    
    /*REQUIRED*/ func loadAction() -> LoadActionLoadableType?
    /*OPTIONAL*/ func updateView()
    
}

public class SAViewController: UIViewController, LoadActionDelegate {
    
    private var isFirstLoad = true
    
    public var viewControllerSubclass: SAViewControllerSubclass!
    
    public func loadNew() {
        viewControllerSubclass.loadAction()?.loadNew()
    }
    
    public func load(forced forced: Bool) {
        viewControllerSubclass.loadAction()?.loadAny(forced: forced, completition: nil)
    }

    /********************************************************************************************************/
    // MARK: View Management Methods
     /********************************************************************************************************/
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set subclasses
        viewControllerSubclass = self as? SAViewControllerSubclass
        
        // Perform setup
        viewControllerSubclass.loadAction()?.addDelegate(self)
    }
    
    public func updateView() {
        // Override in subclass
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstLoad {
            isFirstLoad = false
            
            // Update view
            viewControllerSubclass.updateView()
            
            // Load data
            load(forced: false)
        }
        
    }
    
    /********************************************************************************************************/
    // MARK: Loading Data Methods
     /********************************************************************************************************/
    
    @IBOutlet public var activityIndicatorView: UIActivityIndicatorView? {
        didSet {
            if let activityIndicatorView = activityIndicatorView {
                viewControllerSubclass.loadAction()?.addDelegate(activityIndicatorView)
            }
        }
    }
    
    public func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updatedValues: [LoadActionValues]) {
        print(owner:"SAViewController", items: "LoadActionsUpdated (Status: \(loadAction.status))", level: .Info)
        viewControllerSubclass.updateView()
    }
    
}
