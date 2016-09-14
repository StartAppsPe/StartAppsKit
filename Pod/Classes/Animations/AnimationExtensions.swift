//
//  AnimationExtensions.swift
//  Pods
//
//  Created by Gabriel Lanata on 24/2/16.
//
//

import UIKit

public extension UIView {
    
    public func shake(_ times: Int = 2, distance: Int = 10) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.03*TimeInterval(times)
        animation.repeatCount = Float(times)
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - CGFloat(distance), y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + CGFloat(distance), y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
}
