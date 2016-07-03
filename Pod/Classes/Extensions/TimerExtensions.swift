//
//  TimerExtensions.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 11/16/14.
//  Copyright (c) 2014 StartApps. All rights reserved.
//

import Foundation

public extension NSTimer {
    
    /********************************************************************************************************/
    // MARK: Closure Methods
    /********************************************************************************************************/
    
    public class NSTimerCallbackHolder : NSObject {
        var callback: () -> ()
        
        init(callback: () -> ()) {
            self.callback = callback
        }
        
        func tick(timer: NSTimer) {
            callback()
        }
    }

    public class func scheduledTimer(timeInterval: NSTimeInterval, repeats: Bool, actions: () -> ()) -> NSTimer {
        let holder = NSTimerCallbackHolder(callback: actions)
        holder.callback = actions
        return self.scheduledTimerWithTimeInterval(timeInterval, target: holder, selector: #selector(NSTimerCallbackHolder.tick(_:)), userInfo: nil, repeats: repeats)
    }
    
}
