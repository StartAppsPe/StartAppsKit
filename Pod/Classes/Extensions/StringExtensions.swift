//
//  StringExtensions.swift
//  ULima
//
//  Created by Gabriel Lanata on 2/4/15.
//  Copyright (c) 2015 is.oto.pe. All rights reserved.
//

import Foundation

public extension String {
    
    public var length: Int {
        return self.characters.count
    }
    
    /*func md5() -> String! {
     let str = cStringUsingEncoding(NSUTF8StringEncoding)
     let strLen = CUnsignedInt(lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
     let digestLen = Int(CC_MD5_DIGEST_LENGTH)
     let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
     CC_MD5(str!, strLen, result)
     let hash = NSMutableString()
     for i in 0..<digestLen {
     hash.appendFormat("%02x", result[i])
     }
     result.destroy()
     return String(format: hash as String)
     }*/
    
    public func stringByRemovingHTML() -> String {
        return (try! NSAttributedString(data: dataUsingEncoding(NSUTF8StringEncoding)!,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding],
            documentAttributes: nil)).string
    }
    
    public func substring(range range: Range<Int>) -> String {
        let startIndex = self.startIndex.advancedBy(range.startIndex)
        let endIndex = startIndex.advancedBy(range.endIndex - range.startIndex)
        return self.substringWithRange(startIndex..<endIndex)
    }
    
    public func substring(start start: Int) -> String {
        return self.substring(range: start..<self.length)
    }
    
    public func substring(end end: Int) -> String {
        return self.substring(range: 0..<end)
    }
    
    public func substring(start start: Int, end: Int) -> String {
        return self.substring(range: start..<end)
    }
    
    public func substring(start start: Index) -> String {
        return self.substringWithRange(start..<self.endIndex)
    }
    
    public func substring(end end: Index) -> String {
        return self.substringWithRange(self.startIndex..<end)
    }
    
    public func substring(start start: Index, end: Index) -> String {
        return self.substringWithRange(start..<end)
    }
    
    public func substring(start start: String, end: String) -> String? {
        if let startRange = rangeOfString(start) {
            let newString = self.substring(start: startRange.endIndex)
            if let endRange = newString.rangeOfString(end) {
                return newString.substring(end: endRange.startIndex)
            }
        }
        return nil
    }
    
    public func substring(start start: String) -> String? {
        if let startRange = rangeOfString(start) {
            return substring(start: startRange.endIndex)
        }
        return nil
    }
    
    public func substring(end end: String) -> String? {
        if let endRange = rangeOfString(end) {
            return substring(end: endRange.startIndex)
        }
        return nil
    }
    
    public func trim() -> String {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    public func clean(minSize: Int = 0) -> String? {
        let trimmed = trim()
        return (trimmed.length > minSize ? trimmed : nil)
    }
    
    public func urlEncode() -> String {
        return stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    }
    
    public mutating func capitalizeFirst() {
        guard length > 0 else { return }
        self.replaceRange(startIndex...startIndex, with: String(self[startIndex]).capitalizedString)
    }
    
    public func capitalizedFirstString() -> String {
        guard length > 0 else { return self }
        return self.stringByReplacingCharactersInRange(startIndex...startIndex, withString: String(self[startIndex]).capitalizedString)
    }
    
    public func lowercasedFirstString() -> String {
        return self.stringByReplacingCharactersInRange(startIndex...startIndex, withString: String(self[startIndex]).lowercaseString)
    }
    
    public func justifiedAttributedString() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping
        paragraphStyle.alignment = .Justified
        return NSAttributedString(string: self, attributes: [NSParagraphStyleAttributeName : paragraphStyle, NSBaselineOffsetAttributeName : 0])
    }
    
    public func indexOf(target: String) -> Int {
        let range = self.rangeOfString(target)
        if let range = range {
            return self.startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
    
    public func indexOf(target: String, startIndex: Int) -> Int {
        let startRange = self.startIndex.advancedBy(startIndex)
        let range = self.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: Range<String.Index>(startRange..<self.endIndex))
        if let range = range {
            return self.startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
    
    public func lastIndexOf(target: String) -> Int {
        var index = -1
        var stepIndex = self.indexOf(target)
        while stepIndex > -1 {
            index = stepIndex
            if stepIndex + target.length < self.length {
                stepIndex = indexOf(target, startIndex: stepIndex + target.length)
            } else {
                stepIndex = -1
            }
        }
        return index
    }
}

public extension NSAttributedString {
    
    public convenience init(string: String, font: UIFont?, color: UIColor? = nil) {
        var attributes = [String : AnyObject]()
        if font  != nil { attributes[NSFontAttributeName] = font! }
        if color != nil { attributes[NSForegroundColorAttributeName] = color! }
        self.init(string: string, attributes: attributes)
    }
    
}

public extension NSMutableAttributedString {
    
    public func append(string string: String, font: UIFont? = nil, color: UIColor? = nil) {
        appendAttributedString(NSAttributedString(string: string, font: font, color: color))
    }
    
}


