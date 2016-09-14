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
    
    open class NSTimerCallbackHolder : NSObject {
        var callback: () -> ()
        
        init(callback: @escaping () -> ()) {
            self.callback = callback
        }
        
        func tick(_ timer: Timer) {
            callback()
        }
    }
    
    public class func scheduledTimer(_ timeInterval: TimeInterval, repeats: Bool, actions: @escaping () -> ()) -> Timer {
        let holder = NSTimerCallbackHolder(callback: actions)
        holder.callback = actions
        return self.scheduledTimer(timeInterval: timeInterval, target: holder, selector: #selector(NSTimerCallbackHolder.tick(_:)), userInfo: nil, repeats: repeats)
    }
    
}
