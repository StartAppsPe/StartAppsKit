//
//  RssLoadAction.swift
//  ULima
//
//  Created by Gabriel Lanata on 1/9/16.
//  Copyright © 2016 Universidad de Lima. All rights reserved.
//

import Foundation
import AEXML

public class RssLoadAction: ProcessLoadAction<AEXMLDocument, RssChannel> {
    
    public typealias RssUrlResultType     = Result<NSURL, ErrorType>
    public typealias RssUrlResultClosure  = (result: RssUrlResultType) -> Void
    public typealias RssUrlResult         = (completion: RssUrlResultClosure) -> Void
    
    public var rssUrlClosure:  RssUrlResult
    
    private func urlRequestCreate(completion completion: WebLoadAction.UrlRequestResultClosure) {
        rssUrlClosure() { (rssUrlResult) in
            switch rssUrlResult {
            case .Success(let rssUrl):
                completion(result: .Success(NSMutableURLRequest(URL: rssUrl)))
            case .Failure(let error):
                completion(result: .Failure(error))
            }
        }
        
    }
    
    /**
     Processes data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completion: Closure called when operation finished
     */
    private func processInner(loadedValue loadedValue: AEXMLDocument, completion: ProcessResultClosure) {
        do {
            let channelXml = loadedValue.root["channel"]
            completion(result: .Success(try RssChannel(channelXml: channelXml)))
        } catch(let error) {
            completion(result: .Failure(error))
        }
    }
    
    /**
     Quick initializer with all closures
     
     - parameter load: Closure to load from web, must call result closure when finished
     - parameter delegates: Array containing objects that react to updated data
     */
    public init(
        rssUrl:    RssUrlResult,
        dummy:     (() -> ())? = nil)
    {
        self.rssUrlClosure  = rssUrl
        super.init(
            baseLoadAction: LoadAction<AEXMLDocument>(load: { _ in }),
            process: { _,_ in }
        )
        self.baseLoadAction = XmlLoadAction(
            baseLoadAction: WebLoadAction(
                urlRequest: { (completion) in
                    self.urlRequestCreate(completion: completion)
                }
            )
        )
        self.processClosure = { (loadedValue, completion) -> Void in
            self.processInner(loadedValue: loadedValue, completion: completion)
        }
    }
    
}



// MARK: RSS Objects

public class RssChannel {
    
    public class ImageInfo {
        
        public var rawXml: AEXMLElement?
        
        public var title: String
        public var link: NSURL
        public var url: NSURL
        
        public init(title: String, link: NSURL, url: NSURL) {
            self.title = title
            self.link = link
            self.url = url
        }
        
        public convenience init(channelImageXml: AEXMLElement) throws {
            guard let title = channelImageXml["title"].value,
                linkString = channelImageXml["link"].value, link = NSURL(string: linkString),
                urlString = channelImageXml["url"].value, url = NSURL(string: urlString) else {
                    throw NSError(domain: "LoadAction[Rss]", code: 2274, description: "Faltan parámetros en canal")
            }
            self.init(title: title, link: link, url: url)
            self.rawXml = channelImageXml
        }
        
    }
    
    public class Item {
        
        public class Enclosure {
            
            public var rawXml: AEXMLElement?
            
            public var url: NSURL
            public var length: String
            public var type: String
            
            public init(url: NSURL, length: String, type: String) {
                self.url = url
                self.length = length
                self.type = type
            }
            
            public convenience init(enclosureXml: AEXMLElement) throws {
                guard let urlString = enclosureXml.attributes["url"], url = NSURL(string: urlString),
                    length = enclosureXml.attributes["length"], type = enclosureXml.attributes["type"] else {
                        throw NSError(domain: "LoadAction[Rss]", code: 2275, description: "Faltan parámetros en enclosure")
                }
                self.init(url: url, length: length, type: type)
                self.rawXml = enclosureXml
            }
            
        }
        
        public var rawXml: AEXMLElement?
        
        public var title: String
        public var description: String
        public var link: NSURL
        
        public var author: String?
        public var comments: NSURL?
        public var enclosure: Enclosure?
        public var pubDate: NSDate?
        
        public init(title: String, description: String, link: NSURL) {
            self.title = title
            self.description = description
            self.link = link
        }
        
        public convenience init(itemXml: AEXMLElement) throws {
            guard let title = itemXml["title"].value, description = itemXml["description"].value,
                linkString = itemXml["link"].value, link = NSURL(string: linkString) else {
                    throw NSError(domain: "LoadAction[Rss]", code: 2276, description: "Faltan parámetros en item")
            }
            self.init(title: title, description: description, link: link)
            self.rawXml = itemXml
            self.author = itemXml["author"].value
            self.comments = itemXml["comments"].value.flatMap({ NSURL(string: $0) })
            self.enclosure = itemXml["enclosure"].first.flatMap({ try? Enclosure(enclosureXml: $0) })
            if let dateString = itemXml["pubDate"].value {
                self.pubDate = NSDate(string: dateString, format: "EEE, dd MMM yyyy HH:mm:ss ZZZ", locale: "en_US_POSIX")!
            }
        }
        
    }
    
    public var rawXml: AEXMLElement?
    
    public var title: String
    public var description: String
    public var link: NSURL
    
    public var category:  String?
    public var copyright: String?
    public var language:  String?
    public var imageInfo: ImageInfo?
    
    public var items: [Item] = []
    
    public init(title: String, description: String, link: NSURL) {
        self.title = title
        self.description = description
        self.link = link
    }
    
    public convenience init(channelXml: AEXMLElement) throws {
        
        guard channelXml.xmlString.length > 20 else {
            throw NSError(domain: "LoadAction[Rss]", code: 2283, description: "Respuesta vacía")
        }
        
        print("CVSGBSHNS1",channelXml.xmlString)
        
        guard let title = channelXml["title"].value,
            linkString = channelXml["link"].value, link = NSURL(string: linkString) else {
                throw NSError(domain: "LoadAction[Rss]", code: 2285, description: "Faltan parámetros en canal")
        }
        let description = channelXml["description"].value ?? ""
        
        self.init(title: title, description: description, link: link)
        self.rawXml    = channelXml
        self.category  = channelXml["category"].value
        self.copyright = channelXml["copyright"].value
        self.language  = channelXml["language"].value
        self.imageInfo = channelXml["image"].first.flatMap({ try? ImageInfo(channelImageXml: $0) })
        self.items     = try channelXml["item"].all?.flatMap({ try Item(itemXml: $0) }) ?? []
    }
    
}
