//
//  AnimationSegue.swift
//  Pods
//
//  Created by Gabriel Lanata on 24/2/16.
//
//

import UIKit

public class AnimationSegue: UIStoryboardSegue {
    
    public var delay: NSTimeInterval = 0
    public var duration: NSTimeInterval = 1
    public var options: UIViewKeyframeAnimationOptions = [.BeginFromCurrentState]
    
    public var transitions: [AnimationSegueTransition] = []
    
    public override func perform() {
        // Assign the source and destination views to local variables.
        let firstVCView = self.sourceViewController.view as UIView!
        let secondVCView = self.destinationViewController.view as UIView!
        
        // Specify the initial position of the destination view.
        secondVCView.frame = firstVCView.frame
        secondVCView.alpha = 0
        
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
        secondVCView.layoutIfNeeded()
        
        for transition in self.transitions {
            transition.prepareAnimationsClosure()()
        }
        
        // Animate the transition.
        UIView.animateKeyframesWithDuration(duration, delay: delay, options: options,
            animations: { () -> Void in
                for transition in self.transitions {
                    UIView.addKeyframeWithRelativeStartTime(transition.start, relativeDuration: transition.duration,
                        animations: transition.animationsClosure())
                }
            },
            completion: { (Finished) -> Void in
                self.sourceViewController.presentViewController(self.destinationViewController as UIViewController, animated: false, completion: nil)
                for transition in self.transitions {
                    transition.finishAnimationsClosure()()
                }
            }
        )
    }
    
    public func addTransition(transition: AnimationSegueTransition) {
        transitions.append(transition)
    }
    
}

public enum AnimationSegueTransitionType {
    case Action, Match, FadeOut, FadeIn, EnterUp, EnterDown, EnterLeft, EnterRight, LeaveUp, LeaveDown, LeaveLeft, LeaveRight
}

public class AnimationSegueTransition {
    
    private var view: (() -> UIView)?
    private var toView: (() -> UIView)?
    private var actions: (() -> Void)?
    
    public var type: AnimationSegueTransitionType
    
    public var start: NSTimeInterval
    public var duration: NSTimeInterval
    
    private func prepareAnimationsClosure() -> (() -> Void) {
        return { () -> Void in
            switch self.type {
                
            case .Action:
                break
                
            case .Match:
                let window = UIApplication.sharedApplication().keyWindow!
                let from = self.view!().superview!.convertRect(self.view!().frame, toView: window)
                let to = self.toView!().superview!.convertRect(self.toView!().frame, toView: window)
                
                var transform = CGAffineTransformIdentity;
                transform = CGAffineTransformScale(transform, CGRectGetWidth(from)/CGRectGetWidth(to), CGRectGetHeight(from)/CGRectGetHeight(to))
                transform = CGAffineTransformTranslate(transform, CGRectGetMidX(from)-CGRectGetMidX(to), CGRectGetMidY(from)-CGRectGetMidY(to))
                
                self.toView!().transform = transform
                
            case .FadeOut:
                self.view!().alpha = 1
            case .FadeIn:
                self.view!().alpha = 0
                
            case .EnterUp:
                let window = UIApplication.sharedApplication().keyWindow!
                let from = self.view!().superview!.convertRect(self.view!().frame, toView: window)
                self.view!().transform = CGAffineTransformMakeTranslation(0, (-CGRectGetMaxY(from))-CGRectGetMinY(from))
            case .EnterDown:
                let window = UIApplication.sharedApplication().keyWindow!
                let from = self.view!().superview!.convertRect(self.view!().frame, toView: window)
                self.view!().transform = CGAffineTransformMakeTranslation(0, CGRectGetMaxY(window.frame)-CGRectGetMinY(from))
            case .EnterLeft:
                let window = UIApplication.sharedApplication().keyWindow!
                let from = self.view!().superview!.convertRect(self.view!().frame, toView: window)
                self.view!().transform = CGAffineTransformMakeTranslation((-CGRectGetMaxX(from))-CGRectGetMinX(from), 0)
            case .EnterRight:
                let window = UIApplication.sharedApplication().keyWindow!
                let from = self.view!().superview!.convertRect(self.view!().frame, toView: window)
                self.view!().transform = CGAffineTransformMakeTranslation(CGRectGetMaxX(window.frame)-CGRectGetMinX(from), 0)
                
            case .LeaveUp:
                break
            case .LeaveDown:
                break
            case .LeaveLeft:
                break
            case .LeaveRight:
                break
            }
        }
    }
    
    private func animationsClosure() -> (() -> Void) {
        return { () -> Void in
            switch self.type {
                
            case .Action:
                self.actions!()
                
            case .Match:
                //let window = UIApplication.sharedApplication().keyWindow!
                //let from = self.view!().superview!.convertRect(self.view!().frame, toView: window)
                //let to = self.toView!().superview!.convertRect(self.toView!().frame, toView: window)
                //let translate = CGAffineTransformMakeTranslation(CGRectGetMidX(to)-CGRectGetMidX(from), CGRectGetMidY(to)-CGRectGetMidY(from))
                //let scale = CGAffineTransformMakeScale(to.width/from.width, to.height/from.height)
                self.view!().transform = CGAffineTransformInvert(self.toView!().transform)
                self.toView!().transform = CGAffineTransformIdentity
                
            case .FadeOut:
                self.view!().alpha = 0
            case .FadeIn:
                self.view!().alpha = 1
                
            case .EnterUp:
                self.view!().transform = CGAffineTransformIdentity
            case .EnterDown:
                self.view!().transform = CGAffineTransformIdentity
            case .EnterLeft:
                self.view!().transform = CGAffineTransformIdentity
            case .EnterRight:
                self.view!().transform = CGAffineTransformIdentity
                
            case .LeaveUp:
                let window = UIApplication.sharedApplication().keyWindow!
                let from = self.view!().superview!.convertRect(self.view!().frame, toView: window)
                self.view!().transform = CGAffineTransformMakeTranslation(0, (-CGRectGetMaxY(from))-CGRectGetMinY(from))
            case .LeaveDown:
                let window = UIApplication.sharedApplication().keyWindow!
                let from = self.view!().superview!.convertRect(self.view!().frame, toView: window)
                self.view!().transform = CGAffineTransformMakeTranslation(0, CGRectGetMaxY(window.frame)-CGRectGetMinY(from))
            case .LeaveLeft:
                let window = UIApplication.sharedApplication().keyWindow!
                let from = self.view!().superview!.convertRect(self.view!().frame, toView: window)
                self.view!().transform = CGAffineTransformMakeTranslation((-CGRectGetMaxX(from))-CGRectGetMinX(from), 0)
            case .LeaveRight:
                let window = UIApplication.sharedApplication().keyWindow!
                let from = self.view!().superview!.convertRect(self.view!().frame, toView: window)
                self.view!().transform = CGAffineTransformMakeTranslation(CGRectGetMaxX(window.frame)-CGRectGetMinX(from), 0)
            }
        }
    }
    
    private func finishAnimationsClosure() -> (() -> Void) {
        return { () -> Void in
            self.view?().alpha = 1
            self.view?().transform = CGAffineTransformIdentity
        }
    }
    
    public init(start: NSTimeInterval = 0, duration: NSTimeInterval = 1,
        view: (() -> UIView), toView: (() -> UIView)) {
            self.view = view
            self.toView = toView
            self.actions = nil
            self.type = .Match
            self.start = start
            self.duration = duration
    }
    
    public init(start: NSTimeInterval = 0, duration: NSTimeInterval = 1,
        view: (() -> UIView), withType type: AnimationSegueTransitionType) {
            self.view = view
            self.toView = nil
            self.actions = nil
            self.type = type
            self.start = start
            self.duration = duration
    }
    
    public init(start: NSTimeInterval = 0,
        actions: (() -> Void)) {
            self.view = nil
            self.toView = nil
            self.actions = actions
            self.type = .Action
            self.start = start
            self.duration = 0
    }
    
}