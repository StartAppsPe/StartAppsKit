//
//  WebLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 2/10/16.
//
//

import Foundation

let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue.mainQueue())

public class WebLoadAction<T>: LoadAction<T> {
    
    public typealias UrlRequestResultType    = Result<NSURLRequest, ErrorType>
    public typealias UrlRequestResultClosure = (result: UrlRequestResultType) -> Void
    public typealias UrlRequestResult        = (forced: Bool, completion: UrlRequestResultClosure) -> Void
    
    public typealias ProcessDataResultType    = Result<T, ErrorType>
    public typealias ProcessDataResultClosure = (result: ProcessDataResultType) -> Void
    public typealias ProcessDataResult        = (forced: Bool, loadedData: NSData, completion: ProcessDataResultClosure) -> Void
    
    public var urlRequestClosure:  UrlRequestResult
    public var processDataClosure: ProcessDataResult?
    
    /**
     Loads data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completion: Closure called when operation finished
     */
    private func loadInner(forced forced: Bool, completion: LoadResultClosure) {
        urlRequestClosure(forced: forced) { (result) -> Void in
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
                        let error = NSError(domain: "", code: 33, description: "")
                        completion(result: .Failure(error))
                        return
                    }
                    self.processData(forced: forced, loadedData: loadedData, completion: completion)
                }).resume()
            }
        }
    }
    
    /**
     Processes data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completion: Closure called when operation finished
     */
    private func processData(forced forced: Bool, loadedData: NSData, completion: LoadResultClosure) {
        if let processClosure = self.processDataClosure {
            processClosure(forced: forced, loadedData: loadedData) { (result) -> Void in
                switch result {
                case .Success(let processedData):
                    completion(result: .Success(processedData))
                case .Failure(let error):
                    completion(result: .Failure(error))
                }
            }
        } else if let processedData = loadedData as? T {
            completion(result: .Success(processedData))
        } else {
            print(owner: "LoadAction[Web]", items: "ProcessClosure not defined when return type is different than NSData", level: .Error)
            completion(result: .Failure(NSError(domain: "LoadAction[Web]", code: 837, description: "ProcessClosure not defined when return type is different than NSData")))
        }
    }
    
    /**
     Quick initializer with all closures
     
     - parameter load: Closure to load from web, must call result closure when finished
     - parameter delegates: Array containing objects that react to updated data
     */
    public init(
        urlRequest: UrlRequestResult,
        process:    ProcessDataResult?,
        delegates:  [LoadActionDelegate] = [],
        dummy:      (() -> ())? = nil)
    {
        self.urlRequestClosure  = urlRequest
        self.processDataClosure = process
        super.init(
            load:      { _,_ in },
            delegates: delegates
        )
        loadClosure = { (forced, result) -> Void in
            self.loadInner(forced: forced, completion: result)
        }
    }
}
