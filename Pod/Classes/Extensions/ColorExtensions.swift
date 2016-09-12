//
//  ColorExtensions.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 11/16/14.
//  Credits to PaintCode App (PixelCut)
//  Copyright (c) 2014 StartApps. All rights reserved.
//  Version: 1.0
//

import UIKit

public extension UIColor {
    
    public func colorWithHue(newHue: CGFloat) -> UIColor {
        var saturation: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(nil, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    public func colorWithSaturation(newSaturation: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
    
    public func colorWithBrightness(newBrightness: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: nil, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
    
    public func colorWithAlpha(newAlpha: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, brightness: CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: newAlpha)
    }
    
    public func colorWithHighlight(highlight: CGFloat) -> UIColor {
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-highlight) + highlight, green: green * (1-highlight) + highlight, blue: blue * (1-highlight) + highlight, alpha: alpha)
    }
    
    public func colorWithShadow(shadow: CGFloat) -> UIColor {
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-shadow), green: green * (1-shadow), blue: blue * (1-shadow), alpha: alpha)
    }
    
    public func blendedColorWithFraction(fraction: CGFloat, ofColor color: UIColor) -> UIColor {
        var r1: CGFloat = 1.0, g1: CGFloat = 1.0, b1: CGFloat = 1.0, a1: CGFloat = 1.0
        var r2: CGFloat = 1.0, g2: CGFloat = 1.0, b2: CGFloat = 1.0, a2: CGFloat = 1.0
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(red: r1 * (1 - fraction) + r2 * fraction,
            green: g1 * (1 - fraction) + g2 * fraction,
            blue: b1 * (1 - fraction) + b2 * fraction,
            alpha: a1 * (1 - fraction) + a2 * fraction);
    }
    
    public var components: [CGFloat] {
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red,green,blue,alpha]
    }
    
    public var alpha: CGFloat {
        return CGColorGetAlpha(self.CGColor)
    }
    
    public convenience init(hex: String) {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        if (cString.hasPrefix("#")) { cString = cString.substringFromIndex(cString.startIndex.advancedBy(1)) }
        if (cString.characters.count != 6) {
            self.init(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
        } else {
            var rgbValue:UInt32 = 0
            NSScanner(string: cString).scanHexInt(&rgbValue)
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }
    }
    
    public var hexString: String {
        let components = CGColorGetComponents(self.CGColor)
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255),lroundf(g * 255),lroundf(b * 255))
    }
    
}

public extension UIColor {
    
    public convenience init(r: Int, g:Int, b:Int, a: Int = 255) {
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
    }
    
    public class func flatLightTurquoiseColor()->UIColor {
        return UIColor(r: 26, g: 188, b: 156)
    }
    
    public class func flatTurquoiseColor()->UIColor {
        return UIColor(r: 22, g: 160, b: 133)
    }
    
    public class func flatLightGreenColor()->UIColor {
        return UIColor(r: 46, g: 204, b: 113)
    }
    
    public class func flatGreenColor()->UIColor {
        return UIColor(r: 39, g: 174, b: 96)
    }
    
    public class func flatLightBlueColor()->UIColor {
        return UIColor(r: 52, g: 152, b: 219)
    }
    
    public class func flatBlueColor()->UIColor {
        return UIColor(r: 41, g: 128, b: 185)
    }
    
    public class func flatLightPurpleColor()->UIColor {
        return UIColor(r:155, g:89, b:182)
    }
    
    public class func flatPurpleColor()->UIColor {
        return UIColor(r:142, g:68, b:173)
    }
    
    public class func flatLightLeadColor()->UIColor {
        return UIColor(r:52, g:73, b:94)
    }
    
    public class func flatLeadColor()->UIColor {
        return UIColor(r:44, g:62, b:80)
    }
    
    public class func flatYellowColor()->UIColor {
        return UIColor(r:241, g:196, b:15)
    }
    
    public class func flatLightOrangeColor()->UIColor {
        return UIColor(r:230, g:126, b:34)
    }
    
    public class func flatOrangeColor()->UIColor {
        return UIColor(r:211, g:84, b:0)
    }
    
    public class func flatLightRedColor()->UIColor {
        return UIColor(r:231, g:76, b:60)
    }
    
    public class func flatRedColor()->UIColor {
        return UIColor(r:192, g:57, b:43)
    }
    
    public class func flatVeryLightGray()->UIColor {
        return UIColor(r:236, g:240, b:241)
    }
    
    public class func flatLightGray()->UIColor {
        return UIColor(r:189, g:195, b:199)
    }
    
    public class func flatGray()->UIColor {
        return UIColor(r:149, g:165, b:166)
    }
    
    public class func flatDarkGray()->UIColor {
        return UIColor(r:127, g:140, b:141)
    }
    
}