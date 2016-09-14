//
//  AnimationSegue.swift
//  Pods
//
//  Created by Gabriel Lanata on 24/2/16.
//
//

import UIKit

open class AnimationSegue: UIStoryboardSegue {
    
    open var delay: TimeInterval = 0
    open var duration: TimeInterval = 1
    open var options: UIViewKeyframeAnimationOptions = [.beginFromCurrentState]
    
    open var transitions: [AnimationSegueTransition] = []
    
    open override func perform() {
        // Assign the source and destination views to local variables.
        let firstVCView = self.source.view as UIView!
        let secondVCView = self.destination.view as UIView!
        
        // Specify the initial position of the destination view.
        secondVCView?.frame = (firstVCView?.frame)!
        secondVCView?.alpha = 0
        
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(secondVCView!, aboveSubview: firstVCView!)
        secondVCView?.layoutIfNeeded()
        
        for transition in self.transitions {
            transition.prepareAnimationsClosure()()
        }
        
        // Animate the transition.
        UIView.animateKeyframes(withDuration: duration, delay: delay, options: options,
            animations: { () -> Void in
                for transition in self.transitions {
                    UIView.addKeyframe(withRelativeStartTime: transition.start, relativeDuration: transition.duration,
                        animations: transition.animationsClosure())
                }
            },
            completion: { (Finished) -> Void in
                self.source.present(self.destination as UIViewController, animated: false, completion: nil)
                for transition in self.transitions {
                    transition.finishAnimationsClosure()()
                }
            }
        )
    }
    
    open func addTransition(_ transition: AnimationSegueTransition) {
        transitions.append(transition)
    }
    
}

public enum AnimationSegueTransitionType {
    case action, match, fadeOut, fadeIn, enterUp, enterDown, enterLeft, enterRight, leaveUp, leaveDown, leaveLeft, leaveRight
}

open class AnimationSegueTransition {
    
    fileprivate var view: (() -> UIView)?
    fileprivate var toView: (() -> UIView)?
    fileprivate var actions: (() -> Void)?
    
    open var type: AnimationSegueTransitionType
    
    open var start: TimeInterval
    open var duration: TimeInterval
    
    fileprivate func prepareAnimationsClosure() -> (() -> Void) {
        return { () -> Void in
            switch self.type {
                
            case .action:
                break
                
            case .match:
                let window = UIApplication.shared.keyWindow!
                let from = self.view!().superview!.convert(self.view!().frame, to: window)
                let to = self.toView!().superview!.convert(self.toView!().frame, to: window)
                
                var transform = CGAffineTransform.identity;
                transform = transform.scaledBy(x: from.width/to.width, y: from.height/to.height)
                transform = transform.translatedBy(x: from.midX-to.midX, y: from.midY-to.midY)
                
                self.toView!().transform = transform
                
            case .fadeOut:
                self.view!().alpha = 1
            case .fadeIn:
                self.view!().alpha = 0
                
            case .enterUp:
                let window = UIApplication.shared.keyWindow!
                let from = self.view!().superview!.convert(self.view!().frame, to: window)
                self.view!().transform = CGAffineTransform(translationX: 0, y: (-from.maxY)-from.minY)
            case .enterDown:
                let window = UIApplication.shared.keyWindow!
                let from = self.view!().superview!.convert(self.view!().frame, to: window)
                self.view!().transform = CGAffineTransform(translationX: 0, y: window.frame.maxY-from.minY)
            case .enterLeft:
                let window = UIApplication.shared.keyWindow!
                let from = self.view!().superview!.convert(self.view!().frame, to: window)
                self.view!().transform = CGAffineTransform(translationX: (-from.maxX)-from.minX, y: 0)
            case .enterRight:
                let window = UIApplication.shared.keyWindow!
                let from = self.view!().superview!.convert(self.view!().frame, to: window)
                self.view!().transform = CGAffineTransform(translationX: window.frame.maxX-from.minX, y: 0)
                
            case .leaveUp:
                break
            case .leaveDown:
                break
            case .leaveLeft:
                break
            case .leaveRight:
                break
            }
        }
    }
    
    fileprivate func animationsClosure() -> (() -> Void) {
        return { () -> Void in
            switch self.type {
                
            case .action:
                self.actions!()
                
            case .match:
                //let window = UIApplication.sharedApplication().keyWindow!
                //let from = self.view!().superview!.convertRect(self.view!().frame, toView: window)
                //let to = self.toView!().superview!.convertRect(self.toView!().frame, toView: window)
                //let translate = CGAffineTransformMakeTranslation(CGRectGetMidX(to)-CGRectGetMidX(from), CGRectGetMidY(to)-CGRectGetMidY(from))
                //let scale = CGAffineTransformMakeScale(to.width/from.width, to.height/from.height)
                self.view!().transform = self.toView!().transform.inverted()
                self.toView!().transform = CGAffineTransform.identity
                
            case .fadeOut:
                self.view!().alpha = 0
            case .fadeIn:
                self.view!().alpha = 1
                
            case .enterUp:
                self.view!().transform = CGAffineTransform.identity
            case .enterDown:
                self.view!().transform = CGAffineTransform.identity
            case .enterLeft:
                self.view!().transform = CGAffineTransform.identity
            case .enterRight:
                self.view!().transform = CGAffineTransform.identity
                
            case .leaveUp:
                let window = UIApplication.shared.keyWindow!
                let from = self.view!().superview!.convert(self.view!().frame, to: window)
                self.view!().transform = CGAffineTransform(translationX: 0, y: (-from.maxY)-from.minY)
            case .leaveDown:
                let window = UIApplication.shared.keyWindow!
                let from = self.view!().superview!.convert(self.view!().frame, to: window)
                self.view!().transform = CGAffineTransform(translationX: 0, y: window.frame.maxY-from.minY)
            case .leaveLeft:
                let window = UIApplication.shared.keyWindow!
                let from = self.view!().superview!.convert(self.view!().frame, to: window)
                self.view!().transform = CGAffineTransform(translationX: (-from.maxX)-from.minX, y: 0)
            case .leaveRight:
                let window = UIApplication.shared.keyWindow!
                let from = self.view!().superview!.convert(self.view!().frame, to: window)
                self.view!().transform = CGAffineTransform(translationX: window.frame.maxX-from.minX, y: 0)
            }
        }
    }
    
    fileprivate func finishAnimationsClosure() -> (() -> Void) {
        return { () -> Void in
            self.view?().alpha = 1
            self.view?().transform = CGAffineTransform.identity
        }
    }
    
    public init(start: TimeInterval = 0, duration: TimeInterval = 1,
        view: @escaping (() -> UIView), toView: @escaping (() -> UIView)) {
            self.view = view
            self.toView = toView
            self.actions = nil
            self.type = .match
            self.start = start
            self.duration = duration
    }
    
    public init(start: TimeInterval = 0, duration: TimeInterval = 1,
        view: @escaping (() -> UIView), withType type: AnimationSegueTransitionType) {
            self.view = view
            self.toView = nil
            self.actions = nil
            self.type = type
            self.start = start
            self.duration = duration
    }
    
    public init(start: TimeInterval = 0,
        actions: @escaping (() -> Void)) {
            self.view = nil
            self.toView = nil
            self.actions = actions
            self.type = .action
            self.start = start
            self.duration = 0
    }
    
}
