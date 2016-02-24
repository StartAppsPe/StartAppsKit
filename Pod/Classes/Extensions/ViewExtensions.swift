//
//  SA.swift
//  Aprils
//
//  Created by Gabriel Lanata on 12/5/14.
//  Copyright (c) 2014 StartApps. All rights reserved.
//

import UIKit

//public class MessageViewController: UIViewController {
//    
//    public var message: String?
//    
//    public init(title: String?, message: String? = nil) {
//        super.init(nibName: nil, bundle: nil)
//        self.title = title
//        self.message = message
//    }
//
//    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    public override func loadView() {
//        super.loadView()
//        self.view = UIView()
//    }
//    
//    public func show(overView: UIView) {
//        self.view.frame = overView.frame
//        overView.superview?.addSubview(self.view)
//    }
//    
//    public lazy var titleLabel = UILabel
//    
//    public func updateView() {
//        
//    }
//    
//}


public extension UIView {
    
    public func shake(times: Int = 2, distance: Int = 10) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.03*NSTimeInterval(times)
        animation.repeatCount = Float(times)
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.center.x - CGFloat(distance), self.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.center.x + CGFloat(distance), self.center.y))
        self.layer.addAnimation(animation, forKey: "position")
    }
    
}


public extension UIView {
    
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius  = newValue
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
    
    public func updateLayerEffects() {
        if shadowOpacity != 0 {
            layer.shadowOffset  = CGSizeMake(0, 0);
            layer.masksToBounds = false
        } else if cornerRadius != 0 {
            layer.masksToBounds = true
        }
    }
    
}
