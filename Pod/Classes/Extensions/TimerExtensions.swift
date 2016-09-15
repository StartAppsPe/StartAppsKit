//
//  TimerExtensions.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 11/16/14.
//  Copyright (c) 2014 StartApps. All rights reserved.
//

import Foundation

public extension Timer {
    
    /********************************************************************************************************/
    // MARK: Closure Methods
    /********************************************************************************************************/
    
    public typealias TimerCallback = (Timer) -> Void
    
    private class TimerCallbackHolder : NSObject {
        var callback: TimerCallback
        
        init(callback: @escaping TimerCallback) {
            self.callback = callback
        }
        
        func tick(_ timer: Timer) {
            callback(timer)
        }
    }
    
    @discardableResult
    public convenience init(timeInterval interval: TimeInterval, repeats: Bool, actions: @escaping TimerCallback) {
        if #available(iOS 10.0, *) {
            self.init(timeInterval: interval, repeats: repeats, block: actions)
        } else {
            let holder = TimerCallbackHolder(callback: actions)
            holder.callback = actions
            self.init(timeInterval: interval, target: holder, selector: #selector(TimerCallbackHolder.tick(_:)), userInfo: nil, repeats: repeats)
        }
    }
    
    @discardableResult
    public class func scheduledTimer(timeInterval interval: TimeInterval, repeats: Bool, actions: @escaping TimerCallback) -> Timer {
        if #available(iOS 10.0, *) {
            return self.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: actions)
        } else {
            let holder = TimerCallbackHolder(callback: actions)
            holder.callback = actions
            return self.scheduledTimer(timeInterval: interval, target: holder, selector: #selector(TimerCallbackHolder.tick(_:)), userInfo: nil, repeats: repeats)
        }
    }
    
}
