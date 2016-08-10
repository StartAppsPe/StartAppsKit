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

public class WebLoadAction<T>: ProcessLoadAction<NSData, T> {
    
    public typealias UrlRequestResultType    = Result<NSURLRequest, ErrorType>
    public typealias UrlRequestResultClosure = (result: UrlRequestResultType) -> Void
    public typealias UrlRequestResult        = (completion: UrlRequestResultClosure) -> Void
    
    public var urlRequestClosure:  UrlRequestResult
    
    /**
     Loads data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completion: Closure called when operation finished
     */
    private func loadRawInner(completion completion: LoadRawResultClosure) {
        urlRequestClosure() { (result) -> Void in
            switch result {
            case .Failure(let error):
                completion(result: .Failure(error))
            case .Success(let urlRequest):
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
    
    /**
     Quick initializer with all closures
     
     - parameter load: Closure to load from web, must call result closure when finished
     - parameter delegates: Array containing objects that react to updated data
     */
    public init(
        urlRequest: UrlRequestResult,
        process:    ProcessResult? = nil,
        delegates:  [LoadActionDelegate] = [],
        dummy:      (() -> ())? = nil)
    {
        self.urlRequestClosure  = urlRequest
        super.init(
            loadRaw:   { _ in },
            process:   process,
            delegates: delegates
        )
        loadRawClosure = { (result) -> Void in
            self.loadRawInner(completion: result)
        }
    }
}
