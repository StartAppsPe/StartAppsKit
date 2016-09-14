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
public func ?=<T>(lhs: inout T, rhs: @autoclosure () -> T?) {
    if let nv = rhs() { lhs = nv }
}

// If lhs is nil, set value. rhs is not called if lhs is not nil.
infix operator |= { associativity right precedence 90 assignment }
public func |=<T>(lhs: inout T?, rhs: @autoclosure () -> T?) {
    if lhs == nil { lhs = rhs() }
}


public extension UIActivityIndicatorView {
    
    public var active: Bool {
        get {
            return isAnimating
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

public extension UIRefreshControl {
    
    public var active: Bool {
        get {
            return isRefreshing
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
            return (layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) : nil)
        }
        set {
            layer.borderColor = newValue?.cgColor
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
            layer.shadowOffset  = CGSize(width: 0, height: 0);
            layer.masksToBounds = false
        } else if cornerRadius != 0 {
            layer.masksToBounds = true
        }
    }
    
}

public extension UIView {
    
    func addParallax(amount: Int) {
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
                                                               type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -amount
        verticalMotionEffect.maximumRelativeValue = amount
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                 type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -amount
        horizontalMotionEffect.maximumRelativeValue = amount
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        self.addMotionEffect(group)
    }
    
}

public extension UIView {
    
    public func fillWithSubview(_ view: UIView, margin: CGFloat = 0.0) {
        
        // Add view
        view.translatesAutoresizingMaskIntoConstraints = false
        var newFrame = view.frame
        newFrame.size.width = self.bounds.width
        view.layoutIfNeeded()
        view.updateConstraintsIfNeeded()
        view.frame = newFrame
        self.addSubview(view)
        
        // Add constraints
        self.addConstraint(
            NSLayoutConstraint(item: view,
                               attribute: .top, relatedBy: .equal,
                               toItem: self, attribute: .top,
                               multiplier: 1.0, constant: margin
            )
        )
        self.addConstraint(
            NSLayoutConstraint(item: view,
                               attribute: .leading, relatedBy: .equal,
                               toItem: self, attribute: .leading,
                               multiplier: 1.0, constant: margin
            )
        )
        self.addConstraint(
            NSLayoutConstraint(item: self,
                               attribute: .bottom, relatedBy: .equal,
                               toItem: view, attribute: .bottom,
                               multiplier: 1.0, constant: margin
            )
        )
        self.addConstraint(
            NSLayoutConstraint(item: self,
                               attribute: .trailing, relatedBy: .equal,
                               toItem: view, attribute: .trailing,
                               multiplier: 1.0, constant: margin
            )
        )
        
    }
    
}

public extension UIViewController {
    
    public func insertChild(viewController: UIViewController, inView: UIView) {
        addChildViewController(viewController)
        viewController.willMove(toParentViewController: self)
        inView.fillWithSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }
    
    public func removeChild(viewController: UIViewController) {
        viewController.removeFromParentViewController()
        viewController.willMove(toParentViewController: nil)
        viewController.view?.removeFromSuperview()
        viewController.didMove(toParentViewController: nil)
    }
    
}
