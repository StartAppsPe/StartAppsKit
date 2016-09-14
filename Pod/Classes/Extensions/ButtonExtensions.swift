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
        get { return self.image(for: UIControlState()) }
        set { setImage(newValue, for: UIControlState()) }
    }
    
    public var backgroundImage: UIImage? {
        get { return self.backgroundImage(for: UIControlState()) }
        set { setBackgroundImage(newValue, for: UIControlState()) }
    }
    
    public var textColor: UIColor? {
        get { return titleColor(for: UIControlState()) }
        set { setTitleColor(newValue, for: UIControlState()) }
    }
    
    public var titleFont: UIFont? {
        get { return titleLabel?.font }
        set { titleLabel?.font = newValue }
    }
    
    public var title: String? {
        get {
            return self.title(for: UIControlState())
        }
        set {
            setTitle(newValue, for: UIControlState())
            titleOriginal = newValue
        }
    }
    
    public var tempTitle: String? {
        get {
            return (self.title(for: UIControlState()) != titleOriginal ? self.title(for: UIControlState()) : nil)
        }
        set {
            if let newValue = newValue {
                if titleOriginal == nil { titleOriginal = title }
                setTitle(newValue, for: UIControlState())
            } else {
                setTitle(titleOriginal, for: UIControlState())
            }
        }
    }
    
    public var errorTitle: String? {
        get { return objc_getAssociatedObject(self, &_etak) as? String }
        set { objc_setAssociatedObject(self, &_etak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
    }
    
    public var activityIndicatorView: UIActivityIndicatorView? {
        get { return objc_getAssociatedObject(self, &_aiak) as? UIActivityIndicatorView ?? createActivityIndicatorView() }
        set { objc_setAssociatedObject(self, &_aiak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
    }
    
    fileprivate var titleOriginal: String? {
        get { return objc_getAssociatedObject(self, &_toak) as? String }
        set { objc_setAssociatedObject(self, &_toak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
    }
    
    fileprivate func createActivityIndicatorView() -> UIActivityIndicatorView {
        let tempView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        tempView.center    = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        tempView.tintColor = textColor
        tempView.color     = textColor
        tempView.hidesWhenStopped = true
        activityIndicatorView = tempView
        addSubview(tempView)
        return tempView
    }
    
    override open var isHighlighted: Bool {
        didSet {
            if backgroundColor?.alpha ?? 0 == 0 { return }
            if backgroundColorOriginal == nil { backgroundColorOriginal = backgroundColor }
            backgroundColor = backgroundColorOriginal?.colorWithShadow(isHighlighted ? 0.2 : 0.0)
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            if backgroundColor?.alpha ?? 0 == 0 { return }
            if backgroundColorOriginal == nil { backgroundColorOriginal = backgroundColor }
            backgroundColor = backgroundColorOriginal?.colorWithAlpha(isEnabled ? 1.0 : 0.5)
        }
    }
    
    fileprivate var backgroundColorOriginal: UIColor? {
        get { return objc_getAssociatedObject(self, &_bcak) as? UIColor }
        set { objc_setAssociatedObject(self, &_bcak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
    }
    
}

public extension UIGestureRecognizer {
    
    public convenience init(action: ((_ sender: AnyObject) -> Void)?) {
        self.init()
        setAction(action)
    }
    
    public func setAction(_ action: ((_ sender: AnyObject) -> Void)?) {
        if let action = action {
            self.removeTarget(self, action: nil)
            self.addTarget(self, action: #selector(UIGestureRecognizer.performAction))
            self.closuresWrapper = ClosureWrapper(action: action)
        } else {
            self.removeTarget(self, action: nil)
            self.closuresWrapper = nil
        }
    }
    
    public func performAction() {
        self.closuresWrapper?.action(self)
    }
    
    fileprivate var closuresWrapper: ClosureWrapper? {
        get { return objc_getAssociatedObject(self, &_aaak) as? ClosureWrapper }
        set { objc_setAssociatedObject(self, &_aaak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
}

public extension UIControl {
    
    public func setAction(controlEvents: UIControlEvents, action: ((_ sender: AnyObject) -> Void)?) {
        if let action = action {
            self.removeTarget(self, action: nil, for: controlEvents)
            self.addTarget(self, action: #selector(UIControl.performAction), for: controlEvents)
            self.closuresWrapper = ClosureWrapper(action: action)
        } else {
            self.removeTarget(self, action: nil, for: controlEvents)
            self.closuresWrapper = nil
        }
    }
    
    public func performAction() {
        self.closuresWrapper?.action(self)
    }
    
    fileprivate var closuresWrapper: ClosureWrapper? {
        get { return objc_getAssociatedObject(self, &_aaak) as? ClosureWrapper }
        set { objc_setAssociatedObject(self, &_aaak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
}

public extension UIRefreshControl {
    
    public convenience init(color: UIColor? = nil, action: ((_ sender: AnyObject) -> Void)?) {
        self.init()
        setAction(action)
        if let color = color {
            tintColor = color
        }
    }
    
    public func setAction(_ action: ((_ sender: AnyObject) -> Void)?) {
        setAction(controlEvents: .valueChanged, action: action)
    }
    
}


public extension UIButton {
    
    public func setAction(_ action: ((_ sender: AnyObject) -> Void)?) {
        setAction(controlEvents: .touchUpInside, action: action)
    }
    
}

public extension UIBarButtonItem {
    
    public convenience init(barButtonSystemItem systemItem: UIBarButtonSystemItem, action: ((_ sender: AnyObject) -> Void)?) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: #selector(UIBarButtonItem.performAction))
        if let action = action {
            self.closuresWrapper = ClosureWrapper(action: action)
            self.target = self
        }
    }
    
    public convenience init(image: UIImage?, style: UIBarButtonItemStyle, action: ((_ sender: AnyObject) -> Void)?) {
        self.init(image: image, style: style, target: nil, action: #selector(UIBarButtonItem.performAction))
        if let action = action {
            self.closuresWrapper = ClosureWrapper(action: action)
            self.target = self
        }
    }
    
    public convenience init(title: String?, style: UIBarButtonItemStyle, action: ((_ sender: AnyObject) -> Void)?) {
        self.init(title: title, style: style, target: nil, action: #selector(UIBarButtonItem.performAction))
        if let action = action {
            self.closuresWrapper = ClosureWrapper(action: action)
            self.target = self
        }
    }
    
    public func performAction() {
        self.closuresWrapper?.action(self)
    }
    
    fileprivate var closuresWrapper: ClosureWrapper? {
        get { return objc_getAssociatedObject(self, &_aaak) as? ClosureWrapper }
        set { objc_setAssociatedObject(self, &_aaak, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
}

private final class ClosureWrapper {
    fileprivate var action: (_ sender: AnyObject) -> Void
    init(action: @escaping (_ sender: AnyObject) -> Void) {
        self.action = action
    }
}
