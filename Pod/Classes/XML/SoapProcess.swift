//
//  SoapProcess.swift
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
    public static func process(postObjects: [PostObject]) -> String {
        return postObjects.reduce("", {
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

public func SoapProcess(loadedValue: AEXMLDocument) throws -> AEXMLElement {
    guard let loadedSoap = loadedValue.children.first?.children.first?.children.first?.children.first else {
        throw NSError(domain: "LoadAction[SOAP]", code: 8328, description: "Contenido SOAP inválido")
    }
    return loadedSoap
}

public func SoapProcess(loadedValue: Data) throws -> AEXMLElement {
    return try SoapProcess(loadedValue: try XmlProcess(loadedValue))
}

open class SoapLoadAction: ProcessLoadAction<AEXMLDocument, AEXMLElement> {
    
    open var serviceUrl:  URL
    open var serviceName: String
    open var postObjects: [PostObject]
    
    fileprivate func urlRequestCreate() -> URLRequest {
        
        // Create authentication data
        let authData  = "learning space:waswas".data(using: String.Encoding.utf8)!
        let authValue = "Basic \(authData.base64EncodedString(options: []))"
        print(owner: "LoadAction[SOAP]", items: "AuthValue: \(authValue)", level: .verbose)
        
        // Create post body
        let serviceNameL = serviceName.lowercasedFirst()
        var postBody = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:web=\"http://webservice.ul.ulima.edu\">"
        postBody += "<soapenv:Header/><soapenv:Body><web:\(serviceNameL)>"
        postBody += PostObject.process(postObjects: postObjects)
        postBody += "</web:\(serviceNameL)></soapenv:Body></soapenv:Envelope>"
        print(owner: "LoadAction[SOAP]", items: "Posting body = \(postBody)", level: .verbose)
        
        // Create request
        let request = NSMutableURLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.httpBody   = postBody.data(using: String.Encoding.utf8)!
        request.addValue(request.url!.absoluteString,           forHTTPHeaderField: "SOAPAction")
        request.setValue(authValue,                             forHTTPHeaderField: "Authorization")
        request.setValue("application/soap+xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(String(request.httpBody!.count),      forHTTPHeaderField: "Content-Length")
        
        // Respond success
        return request as URLRequest
    }
    
    /**
     Quick initializer with all closures
     
     - parameter load: Closure to load from web, must call result closure when finished
     - parameter delegates: Array containing objects that react to updated data
     */
    public init(
        serviceUrl:  URL,
        serviceName: String,
        postObjects: [PostObject],
        dummy:       (() -> ())? = nil)
    {
        self.serviceUrl  = serviceUrl
        self.serviceName = serviceName
        self.postObjects = postObjects
        super.init(
            baseLoadAction: LoadAction<AEXMLDocument>(load: { _ in }),
            process: SoapProcess
        )
        self.baseLoadAction = WebLoadAction(urlRequest: urlRequestCreate()).then(XmlProcess)
    }
    
}
