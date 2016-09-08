//
//  SoapLoadAction.swift
//  ULima
//
//  Created by Gabriel Lanata on 29/6/16.
//  Copyright © 2016 Universidad de Lima. All rights reserved.
//

import Foundation
import AEXML

public struct PostObject {
    public var key: String
    public var value: Any
    public static func process(postObjects postObjects: [PostObject]) -> String {
        return postObjects.reduce("", combine: {
            let value: Any
            if let valueArray = $1.value as? [PostObject] {
                value = process(postObjects: valueArray)
            } else {
                value = $1.value
            }
            return $0+"<\($1.key)>\(value)</\($1.key)>"
        })
    }
    public init(key: String, value: Any) {
        self.key = key
        self.value = value
    }
}

public class SoapLoadAction: ProcessLoadAction<AEXMLDocument, AEXMLElement> {
    
    public var serviceUrl:  NSURL
    public var serviceName: String
    public var postObjects: [PostObject]
    
    private func urlRequestCreate() -> NSURLRequest {
        
        // Create authentication data
        let authData  = "learning space:waswas".dataUsingEncoding(NSUTF8StringEncoding)!
        let authValue = "Basic \(authData.base64EncodedStringWithOptions([]))"
        print(owner: "LoadAction[SOAP]", items: "AuthValue: \(authValue)", level: .Verbose)
        
        // Create post body
        let serviceNameL = serviceName.lowercasedFirstString()
        var postBody = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:web=\"http://webservice.ul.ulima.edu\">"
        postBody += "<soapenv:Header/><soapenv:Body><web:\(serviceNameL)>"
        postBody += PostObject.process(postObjects: postObjects)
        postBody += "</web:\(serviceNameL)></soapenv:Body></soapenv:Envelope>"
        print(owner: "LoadAction[SOAP]", items: "Posting body = \(postBody)", level: .Verbose)
        
        // Create request
        let request = NSMutableURLRequest(URL: serviceUrl)
        request.HTTPMethod = "POST"
        request.HTTPBody   = postBody.dataUsingEncoding(NSUTF8StringEncoding)!
        request.addValue(request.URL!.absoluteString,           forHTTPHeaderField: "SOAPAction")
        request.setValue(authValue,                             forHTTPHeaderField: "Authorization")
        request.setValue("application/soap+xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(String(request.HTTPBody!.length),      forHTTPHeaderField: "Content-Length")
        
        // Respond success
        return request
        
    }
    
    /**
     Processes data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completion: Closure called when operation finished
     */
    private func processInner(loadedValue loadedValue: AEXMLDocument, completion: ProcessResultClosure) {
        guard let loadedSoap = loadedValue.children.first?.children.first?.children.first?.children.first else {
            let error = NSError(domain: "LoadAction[SOAP]", code: 8328, description: "Contenido SOAP inválido")
            completion(result: .Failure(error))
            return
        }
        completion(result: .Success(loadedSoap))
    }
    
    /**
     Quick initializer with all closures
     
     - parameter load: Closure to load from web, must call result closure when finished
     - parameter delegates: Array containing objects that react to updated data
     */
    public init(
        serviceUrl:  NSURL,
        serviceName: String,
        postObjects: [PostObject],
        dummy:       (() -> ())? = nil)
    {
        self.serviceUrl  = serviceUrl
        self.serviceName = serviceName
        self.postObjects = postObjects
        super.init(
            baseLoadAction: LoadAction<AEXMLDocument>(load: { _ in }),
            process: { _,_ in }
        )
        self.baseLoadAction = XmlLoadAction(
            baseLoadAction: WebLoadAction(urlRequest: urlRequestCreate())
        )
        self.processClosure = { (loadedValue, completion) -> Void in
            self.processInner(loadedValue: loadedValue, completion: completion)
        }
    }
    
}
