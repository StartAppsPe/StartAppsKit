//
//  ButtonExtensions.swift
//  Pods
//
//  Created by Gabriel Lanata on 1/18/16.
//
//

import UIKit

private var _aaak: UInt8 = 0
private var _aiak: UInt8 = 1
private var _toak: UInt8 = 2
private var _etak: UInt8 = 3
private var _bcak: UInt8 = 4

public extension UIButton {
    
    public var image: UIImage? {
        get { return imageForState(.Normal) }
        set { setImage(newValue, forState: .Normal) }
    }
    
    public var backgroundImage: UIImage? {
        get { return backgroundImageForState(.Normal) }
        set { setBackgroundImage(newValue, forState: .Normal) }
    }
    
    public var textColor: UIColor? {
        get { return titleColorForState(.Normal) }
        set { setTitleColor(newValue, forState: .Normal) }
    }
    
    public var title: String? {
        get {
            return titleForState(.Normal)
        }
        set {
            setTitle(newValue, forState: .Normal)
            titleOriginal = newValue
        }
    }
    
    public var tempTitle: String? {
        get {
            return (titleForState(.Normal) != titleOriginal ? titleForState(.Normal) : nil)
        }
        set {
            if let newValue = newValue {
                if titleOriginal == nil { titleOriginal = title }
                setTitle(newValue, forState: .Normal)
            } else {
                setTitle(titleOriginal, forState: .Normal)
            }
        }
    }
    
    public var errorTitle: String? {
        get { return objc_getAssociatedObject(self, &_toak) as? String }
        set { objc_setAssociatedObject(self, &_etak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
    }
    
    public var activityIndicatorView: UIActivityIndicatorView? {
        get { return objc_getAssociatedObject(self, &_aiak) as? UIActivityIndicatorView ?? createActivityIndicatorView() }
        set { objc_setAssociatedObject(self, &_aiak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
    }
    
    private var titleOriginal: String? {
        get { return objc_getAssociatedObject(self, &_toak) as? String }
        set { objc_setAssociatedObject(self, &_toak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
    }
    
    private func createActivityIndicatorView() -> UIActivityIndicatorView {
        let tempView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        tempView.center    = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        tempView.tintColor = UIColor.blackColor()
        tempView.color     = UIColor.blackColor()
        tempView.hidesWhenStopped = true
        activityIndicatorView = tempView
        addSubview(tempView)
        return tempView
    }
    
    override public var highlighted: Bool {
        didSet {
            if backgroundColorOriginal == nil { backgroundColorOriginal = backgroundColor }
            backgroundColor = backgroundColorOriginal?.colorWithShadow(highlighted ? 0.2 : 0.0)
        }
    }
    
    override public var enabled: Bool {
        didSet {
            if backgroundColorOriginal == nil { backgroundColorOriginal = backgroundColor }
            backgroundColor = backgroundColorOriginal?.colorWithAlpha(enabled ? 1.0 : 0.5)
        }
    }
    
    private var backgroundColorOriginal: UIColor? {
        get { return objc_getAssociatedObject(self, &_bcak) as? UIColor }
        set { objc_setAssociatedObject(self, &_bcak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
    }
    
}


public extension UIButton {
    
    public func setAction(action: ((sender: AnyObject) -> Void)?) {
        if let action = action {
            self.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
            self.addTarget(self, action: "performAction", forControlEvents: .TouchUpInside)
            self.closuresWrapper = ClosureWrapper(action: action)
        } else {
            self.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
            self.closuresWrapper = nil
        }
    }
    
    public func performAction() {
        self.closuresWrapper?.action(sender: self)
    }
    
    private var closuresWrapper: ClosureWrapper? {
        get { return objc_getAssociatedObject(self, &_aaak) as? ClosureWrapper }
        set { objc_setAssociatedObject(self, &_aaak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
}

public extension UIBarButtonItem {
    
    public convenience init(barButtonSystemItem systemItem: UIBarButtonSystemItem, action: ((sender: AnyObject) -> Void)?) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: "performAction")
        if let action = action {
            self.closuresWrapper = ClosureWrapper(action: action)
            self.target = self
        }
    }
    
    public convenience init(image: UIImage?, style: UIBarButtonItemStyle, action: ((sender: AnyObject) -> Void)?) {
        self.init(image: image, style: style, target: nil, action: "performAction")
        if let action = action {
            self.closuresWrapper = ClosureWrapper(action: action)
            self.target = self
        }
    }
    
    public convenience init(title: String?, style: UIBarButtonItemStyle, action: ((sender: AnyObject) -> Void)?) {
        self.init(title: title, style: style, target: nil, action: "performAction")
        if let action = action {
            self.closuresWrapper = ClosureWrapper(action: action)
            self.target = self
        }
    }
    
    public func performAction() {
        self.closuresWrapper?.action(sender: self)
    }
    
    private var closuresWrapper: ClosureWrapper? {
        get { return objc_getAssociatedObject(self, &_aaak) as? ClosureWrapper }
        set { objc_setAssociatedObject(self, &_aaak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
}

public extension UIRefreshControl {
    
    public convenience init(color: UIColor? = nil, action: ((sender: AnyObject) -> Void)?) {
        self.init()
        setAction(action)
        if let color = color {
            tintColor = color
        }
    }
    
    public func setAction(action: ((sender: AnyObject) -> Void)?) {
        if let action = action {
            self.removeTarget(self, action: nil, forControlEvents: .ValueChanged)
            self.addTarget(self, action: "performAction", forControlEvents: .ValueChanged)
            self.closuresWrapper = ClosureWrapper(action: action)
        } else {
            self.removeTarget(self, action: nil, forControlEvents: .ValueChanged)
            self.closuresWrapper = nil
        }
    }
    
    public func performAction() {
        self.closuresWrapper?.action(sender: self)
    }
    
    private var closuresWrapper: ClosureWrapper? {
        get { return objc_getAssociatedObject(self, &_aaak) as? ClosureWrapper }
        set { objc_setAssociatedObject(self, &_aaak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
}

private final class ClosureWrapper {
    private var action: (sender: AnyObject) -> Void
    init(action: (sender: AnyObject) -> Void) {
        self.action = action
    }
}