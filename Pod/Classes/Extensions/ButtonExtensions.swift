//
//  ButtonExtensions.swift
//  Pods
//
//  Created by Gabriel Lanata on 1/18/16.
//
//

import Foundation
import UIKit

private var AssociatedActionKey: UInt8 = 0

private final class ClosureWrapper {
    private var action: (sender: UIBarButtonItem) -> Void
    init(action: (sender: UIBarButtonItem) -> Void) {
        self.action = action
    }
}

public extension UIBarButtonItem {
    
    public convenience init(image: UIImage?, style: UIBarButtonItemStyle, action: ((sender: UIBarButtonItem) -> Void)?) {
        self.init(image: image, style: style, target: nil, action: "performAction")
        if let action = action {
            self.closuresWrapper = ClosureWrapper(action: action)
            self.target = self
        }
    }
    
    public convenience init(title: String?, style: UIBarButtonItemStyle, action: ((sender: UIBarButtonItem) -> Void)?) {
        self.init(title: title, style: style, target: nil, action: "performAction")
        if let action = action {
            self.closuresWrapper = ClosureWrapper(action: action)
            self.target = self
        }
    }
    
    private func performAction() {
        self.closuresWrapper?.action(sender: self)
    }
    
    private var closuresWrapper: ClosureWrapper? {
        get { return objc_getAssociatedObject(self, &AssociatedActionKey) as? ClosureWrapper }
        set { objc_setAssociatedObject(self, &AssociatedActionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
}