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
    public typealias UrlRequestResult        = (forced: Bool, completition: UrlRequestResultClosure) -> Void
    
    public typealias ProcessDataResultType       = Result<T, ErrorType>
    public typealias ProcessDataResultClosure    = (result: ProcessDataResultType) -> Void
    public typealias ProcessDataResult           = (forced: Bool, loadedData: NSData, completition: ProcessDataResultClosure) -> Void
    
    public var urlRequestClosure:  UrlRequestResult!
    public var processDataClosure: ProcessDataResult?
    
    /**
     Loads data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completition: Closure called when operation finished
     */
    private func loadInner(forced forced: Bool, completition: LoadResultClosure?) {
        print("Here",212)
        urlRequestClosure(forced: forced) { (result) -> Void in
            print("Here",213)
            switch result {
            case .Failure(let error):
                print("Here",213.1)
                completition?(result: Result.Failure(error))
            case .Success(let urlRequest):
                print("Here",213.2, urlRequest)
                session.dataTaskWithRequest(urlRequest!, completionHandler: { (loadedData, urlResponse, error) -> Void in
                    print("Here",214)
                    if let error = error {
                        var newError = error
                        switch error.code {
                        case -1001, -1003, -1009:
                            newError = NSError(domain: "LoadAction[Web]", code: error.code, userInfo: [NSLocalizedDescriptionKey:"No hay conexión a internet"])
                        default: ()
                        }
                        completition?(result: Result.Failure(newError))
                    } else if let processClosure = self.processDataClosure {
                        processClosure(forced: forced, loadedData: loadedData!) { (result) -> Void in
                            print("Here",215)
                            switch result {
                            case .Success(let processedData):
                                completition?(result: Result.Success(processedData))
                            case .Failure(let error):
                                completition?(result: Result.Failure(error))
                            }
                        }
                    } else if let processedData = loadedData as? T {
                        completition?(result: Result.Success(processedData))
                    } else {
                        print(owner: "LoadAction[Web]", items: "ProcessClosure not defined when return type is different than NSData", level: .Error)
                        completition?(result: Result.Failure(NSError(domain: "LoadAction[Web]", code: 837, description: "ProcessClosure not defined when return type is different than NSData")))
                    }
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
        urlRequest:  UrlRequestResult,
        process:     ProcessDataResult,
        delegates:  [LoadActionDelegate] = [],
        dummy:       (() -> ())? = nil)
    {
        self.urlRequestClosure  = urlRequest
        self.processDataClosure = process
        super.init(
            load: { (forced, result) -> Void in
            },
            delegates: delegates
        )
        loadClosure = { (forced, result) -> Void in
            self.loadInner(forced: forced, completition: result)
        }
    }
}
