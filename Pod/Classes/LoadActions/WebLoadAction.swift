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
        urlRequest: WebLoadAction.UrlRequestResult,
        process:    ProcessResult? = nil,
        dummy:      (() -> ())? = nil)
    {
        super.init(
            baseLoadAction: WebLoadAction(urlRequest: urlRequest),
            process:   process
        )
    }
    
}

public class WebLoadAction: LoadAction<NSData> {
    
    public typealias UrlRequestResultType    = Result<NSURLRequest, ErrorType>
    public typealias UrlRequestResultClosure = (result: UrlRequestResultType) -> Void
    public typealias UrlRequestResult        = (completion: UrlRequestResultClosure) -> Void
    
    public var urlRequestClosure:  UrlRequestResult
    
    private func loadInner(completion completion: LoadResultClosure) {
        urlRequestClosure() { (result) -> Void in
            switch result {
            case .Failure(let error):
                completion(result: .Failure(error))
            case .Success(let urlRequest):
                print(owner: "LoadAction[Web]", items: "Url: \(urlRequest.URL?.absoluteString ?? "-")", level: .Verbose)
                session.dataTaskWithRequest(urlRequest, completionHandler: { (loadedData, urlResponse, error) -> Void in
                    if let error = error {
                        var newError = error
                        switch error.code {
                        case -1001, -1003, -1009:
                            newError = NSError(domain: "LoadAction[Web]", code: error.code, description: "No hay conexión a internet")
                        default: ()
                        }
                        completion(result: .Failure(newError))
                        return
                    }
                    guard let loadedData = loadedData else {
                        let error = NSError(domain: "LoadAction[Web]", code: 33, description: "")
                        completion(result: .Failure(error))
                        return
                    }
                    completion(result: .Success(loadedData))
                }).resume()
            }
        }
    }
    
    public init(
        urlRequest: UrlRequestResult,
        dummy:      (() -> ())? = nil)
    {
        self.urlRequestClosure  = urlRequest
        super.init(
            load: { _ in }
        )
        loadClosure = { (result) -> Void in
            self.loadInner(completion: result)
        }
    }
}






