//
//  StringExtensions.swift
//  ULima
//
//  Created by Gabriel Lanata on 2/4/15.
//  Copyright (c) 2015 is.oto.pe. All rights reserved.
//

import Foundation

public extension String {
    
    public func length() -> Int {
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
        return self.substringWithRange(Range(start: startIndex, end: endIndex))
    }
    
    public func substring(start start: Int) -> String {
        return self.substring(range: start..<length())
    }
    
    public func substring(end end: Int) -> String {
        return self.substring(range: 0..<end)
    }
    
    public func trim() -> String {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    public func clean(minSize: Int = 0) -> String? {
        let trimmed = trim()
        return (trimmed.length() > minSize ? trimmed : nil)
    }
    
    public func urlEncode() -> String {
        return stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    }
    
    public mutating func capitalizeFirst() {
        self.replaceRange(startIndex...startIndex, with: String(self[startIndex]).capitalizedString)
    }
    
    public func capitalizedFirstString() -> String {
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


