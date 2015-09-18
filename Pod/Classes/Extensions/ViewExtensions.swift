//
//  SA.swift
//  Aprils
//
//  Created by Gabriel Lanata on 12/5/14.
//  Copyright (c) 2014 StartApps. All rights reserved.
//

import UIKit

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
