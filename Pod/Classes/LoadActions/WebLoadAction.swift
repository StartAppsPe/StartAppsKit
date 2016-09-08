//
//  WebLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 2/10/16.
//
//

import Foundation

let session = NSURLSession(
    configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
    delegate: nil,
    delegateQueue: NSOperationQueue.mainQueue()
)

public class ProcessWebLoadAction<T>: ProcessLoadAction<NSData, T> {
    
    public init(
        urlRequest: NSURLRequest,
        process:    ProcessResult,
        dummy:      (() -> ())? = nil)
    {
        super.init(
            baseLoadAction: WebLoadAction(urlRequest: urlRequest),
            process:   process
        )
    }
    
}

public class WebLoadAction: LoadAction<NSData> {
    
    public var urlRequest:  NSURLRequest
    
    private func loadInner(completion completion: LoadResultClosure) {
        print(owner: "LoadAction[Web]", items: "Load Began (Url: \(urlRequest.URL?.absoluteString ?? "-"))", level: .Verbose)
        session.dataTaskWithRequest(urlRequest, completionHandler: { (loadedData, urlResponse, error) -> Void in
            if let error = error {
                var newError = error
                switch error.code {
                case -1001, -1003, -1009:
                    newError = NSError(domain: "LoadAction[Web]", code: error.code, description: "No hay conexión a internet")
                default: ()
                }
                print(owner: "LoadAction[Web]", items: "Load Failure, \(newError.localizedDescription) (Url: \(self.urlRequest.URL?.absoluteString ?? "-"))", level: .Error)
                completion(result: .Failure(newError))
                return
            }
            guard let loadedData = loadedData else {
                print(owner: "LoadAction[Web]", items: "Load Failure, empty response (Url: \(self.urlRequest.URL?.absoluteString ?? "-"))", level: .Error)
                let error = NSError(domain: "LoadAction[Web]", code: 33, description: "Data retornada vacía")
                completion(result: .Failure(error))
                return
            }
            print(owner: "LoadAction[Web]", items: "Load Success (Url: \(self.urlRequest.URL?.absoluteString ?? "-"))", level: .Verbose)
            completion(result: .Success(loadedData))
        }).resume()
    }
    
    public init(
        urlRequest: NSURLRequest,
        dummy:      (() -> ())? = nil)
    {
        self.urlRequest  = urlRequest
        super.init(
            load: { _ in }
        )
        loadClosure = { (result) -> Void in
            self.loadInner(completion: result)
        }
    }
}






