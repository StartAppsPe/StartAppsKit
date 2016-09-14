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
        return (try! NSAttributedString(data: data(using: String.Encoding.utf8)!,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8],
            documentAttributes: nil)).string
    }
    
    public func substring(range: Range<Int>) -> String {
        let startIndex = self.characters.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.characters.index(startIndex, offsetBy: range.upperBound - range.lowerBound)
        return self.substring(with: startIndex..<endIndex)
    }
    
    public func substring(start: Int) -> String {
        return self.substring(range: start..<self.length)
    }
    
    public func substring(end: Int) -> String {
        return self.substring(range: 0..<end)
    }
    
    public func substring(start: Int, end: Int) -> String {
        return self.substring(range: start..<end)
    }
    
    public func substring(start: Index) -> String {
        return self.substring(with: start..<self.endIndex)
    }
    
    public func substring(end: Index) -> String {
        return self.substring(with: self.startIndex..<end)
    }
    
    public func substring(start: Index, end: Index) -> String {
        return self.substring(with: start..<end)
    }
    
    public func substring(start: String, end: String) -> String? {
        if let startRange = range(of: start) {
            let newString = self.substring(start: startRange.upperBound)
            if let endRange = newString.range(of: end) {
                return newString.substring(end: endRange.lowerBound)
            }
        }
        return nil
    }
    
    public func substring(start: String) -> String? {
        if let startRange = range(of: start) {
            return substring(start: startRange.upperBound)
        }
        return nil
    }
    
    public func substring(end: String) -> String? {
        if let endRange = range(of: end) {
            return substring(end: endRange.lowerBound)
        }
        return nil
    }
    
    public func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    public func clean(minSize: Int = 0) -> String? {
        let trimmed = trim()
        return (trimmed.length > minSize ? trimmed : nil)
    }
    
    public func urlEncode() -> String {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
    public mutating func uppercaseFirst() {
        guard length > 0 else { return }
        self.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).uppercased())
    }
    
    public mutating func lowercaseFirst() {
        guard length > 0 else { return }
        self.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).lowercased())
    }
    
    public func uppercasedFirst() -> String {
        guard length > 0 else { return self }
        var selfCopy = self
        let first = selfCopy.characters.dropFirst()
        return String(first).uppercased()+selfCopy
    }
    
    public func lowercasedFirst() -> String {
        guard length > 0 else { return self }
        var selfCopy = self
        let first = selfCopy.characters.dropFirst()
        return String(first).uppercased()+selfCopy
    }
    
    public func justifiedAttributed() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .justified
        return NSAttributedString(string: self, attributes: [NSParagraphStyleAttributeName : paragraphStyle, NSBaselineOffsetAttributeName : 0])
    }
    
    public func indexOf(_ target: String) -> Int {
        let range = self.range(of: target)
        if let range = range {
            return self.characters.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }
    
    public func indexOf(_ target: String, startIndex: Int) -> Int {
        let startRange = self.characters.index(self.startIndex, offsetBy: startIndex)
        let range = self.range(of: target, options: NSString.CompareOptions.literal, range: Range<String.Index>(startRange..<self.endIndex))
        if let range = range {
            return self.characters.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }
    
    public func lastIndexOf(_ target: String) -> Int {
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
    
    public func append(string: String, font: UIFont? = nil, color: UIColor? = nil) {
        self.append(NSAttributedString(string: string, font: font, color: color))
    }
    
}


