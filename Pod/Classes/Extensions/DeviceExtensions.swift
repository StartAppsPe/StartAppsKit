//
//  DeviceExtensions.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 8/27/15.
//  Copyright (c) 2015 StartAppsKit. All rights reserved.
//

import UIKit

public extension UIDevice {
    
    public static var platform: String {
        var size: Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
    
    public static var platformString: String {
        let platform = self.platform
        switch platform {
        case "iPhone1,1": return "iPhone 1G"
        case "iPhone1,2": return "iPhone 3G"
        case "iPhone2,1": return "iPhone 3GS"
        case "iPhone3,1": return "iPhone 4"
        case "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4S"
        case "iPhone5,1": return "iPhone 5"
        case "iPhone5,2": return "iPhone 5"
        case "iPhone5,3": return "iPhone 5C"
        case "iPhone6,1": return "iPhone 5S"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone8,1": return "iPhone 6S"
        case "iPhone8,2": return "iPhone 6S Plus"
        case "iPod1,1":   return "iPod Touch 1G"
        case "iPod2,1":   return "iPod Touch 2G"
        case "iPod3,1":   return "iPod Touch 3G"
        case "iPod4,1":   return "iPod Touch 4G"
        case "iPod5,1":   return "iPod Touch 5G"
        case "iPad1,1":   return "iPad"
        case "iPad2,1":   return "iPad 2"      // (WiFi)
        case "iPad2,2":   return "iPad 2"      // (GSM)
        case "iPad2,3":   return "iPad 2"      // (CDMA)
        case "iPad2,4":   return "iPad 2"      // (CDMA)
        case "iPad2,5":   return "iPad Mini"   // (WiFi)
        case "iPad2,6":   return "iPad Mini"
        case "iPad2,7":   return "iPad Mini"   // (GSM+CDMA)
        case "iPad3,1":   return "iPad 3"      // (WiFi)
        case "iPad3,2":   return "iPad 3"      // (GSM+CDMA)
        case "iPad3,3":   return "iPad 3"
        case "iPad3,4":   return "iPad 4"      // (WiFi)
        case "iPad3,5":   return "iPad 4"
        case "iPad3,6":   return "iPad 4"      // (GSM+CDMA)
        case "iPad4,1":   return "iPad Air"    // (WiFi)
        case "iPad4,2":   return "iPad Air"    // (Cellular)
        case "iPad4,4":   return "iPad Mini 2" // (WiFi)
        case "iPad4,5":   return "iPad Mini 2" // (Cellular)
        case "iPad4,6":   return "iPad Mini 2"
        case "iPad4,7":   return "iPad Mini 3"
        case "iPad4,8":   return "iPad Mini 3"
        case "iPad4,9":   return "iPad Mini 3"
        case "iPad5,3":   return "iPad Air 2"
        case "iPad5,4":   return "iPad Air 2"
        case "iPad6,8":   return "iPad Pro"
        case "i386":      return "Simulator"
        case "x86_64":    return "Simulator"
        default:          return platform
        }
    }
    
    
}
