//
//  AnimationExtensions.swift
//  Pods
//
//  Created by Gabriel Lanata on 24/2/16.
//
//

import UIKit

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