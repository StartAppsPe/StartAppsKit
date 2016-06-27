//
//  SA.swift
//  Aprils
//
//  Created by Gabriel Lanata on 12/5/14.
//  Copyright (c) 2014 StartApps. All rights reserved.
//

import UIKit

// If rhs not nil, set value. lhs is not replaced if rhs is nil.
infix operator ?= { associativity right precedence 90 assignment }
public func ?=<T>(inout lhs: T?, @autoclosure rhs: () -> T?) {
    if let nv = rhs() { lhs = nv }
}

// If lhs is nil, set value. rhs is not called if lhs is not nil.
infix operator |= { associativity right precedence 90 assignment }
public func |=<T>(inout lhs: T?, @autoclosure rhs: () -> T?) {
    if lhs == nil { lhs = rhs() }
}


public extension UIActivityIndicatorView {
    
    var animating: Bool {
        get {
            return isAnimating()
        }
        set {
            if newValue {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
    
}

extension UIRefreshControl {
    
    var animating: Bool {
        get {
            return refreshing
        }
        set {
            if newValue {
                beginRefreshing()
            } else {
                endRefreshing()
            }
        }
    }
    
}



public extension UIView {
    
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            if newValue == -1 {
                layer.cornerRadius = self.bounds.size.width/2
            } else {
                layer.cornerRadius = newValue
            }
            updateLayerEffects()
        }
    }
    
    @IBInspectable public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius  = newValue;
            updateLayerEffects()
        }
    }
    
    @IBInspectable public var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
            updateLayerEffects()
        }
    }
    
    @IBInspectable public var borderColor: UIColor? {
        get {
            return (layer.borderColor != nil ? UIColor(CGColor: layer.borderColor!) : nil)
        }
        set {
            layer.borderColor = newValue?.CGColor
            updateLayerEffects()
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
            updateLayerEffects()
        }
    }
    
    public func updateLayerEffects() {
        if shadowOpacity != 0 {
            layer.shadowOffset  = CGSizeMake(0, 0);
            layer.masksToBounds = false
        } else if cornerRadius != 0 {
            layer.masksToBounds = true
        }
    }
    
}



public extension UIViewController {
    
    public func insertChild(viewController viewController: UIViewController, inView: UIView) {
        // Add view controller
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        var newFrame = viewController.view.frame
        newFrame.size.width = inView.bounds.width
        viewController.view.layoutIfNeeded()
        viewController.view.updateConstraintsIfNeeded()
        viewController.view.frame = newFrame
        viewController.view.backgroundColor = UIColor.clearColor()
        
        addChildViewController(viewController)
        viewController.willMoveToParentViewController(self)
        inView.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
        
        inView.addConstraint(
            NSLayoutConstraint(item: viewController.view,
                attribute: .Top, relatedBy: .Equal,
                toItem: inView, attribute: .Top,
                multiplier: 1.0, constant: 0.0
            )
        )
        inView.addConstraint(
            NSLayoutConstraint(item: viewController.view,
                attribute: .Leading, relatedBy: .Equal,
                toItem: inView, attribute: .Leading,
                multiplier: 1.0, constant: 0.0
            )
        )
        inView.addConstraint(
            NSLayoutConstraint(item: viewController.view,
                attribute: .Bottom, relatedBy: .Equal,
                toItem: inView, attribute: .Bottom,
                multiplier: 1.0, constant: 0.0
            )
        )
        inView.addConstraint(
            NSLayoutConstraint(item: viewController.view,
                attribute: .Trailing, relatedBy: .Equal,
                toItem: inView, attribute: .Trailing,
                multiplier: 1.0, constant: 0.0
            )
        )
    }
    
    public func removeChild(viewController viewController: UIViewController) {
        viewController.removeFromParentViewController()
        viewController.willMoveToParentViewController(nil)
        viewController.view?.removeFromSuperview()
        viewController.didMoveToParentViewController(nil)
    }
    
}