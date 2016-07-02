//
//  JsonWebLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 2/10/16.
//
//

import Foundation
import SwiftyJSON

public class JsonWebLoadAction<T>: WebLoadAction<T> {
    
    public typealias UrlRequestResultType    = Result<NSURLRequest, ErrorType>
    public typealias UrlRequestResultClosure = (result: UrlRequestResultType) -> Void
    public typealias UrlRequestResult        = (forced: Bool, completion: UrlRequestResultClosure) -> Void
    
    public typealias ProcessJsonResultType    = Result<T, ErrorType>
    public typealias ProcessJsonResultClosure = (result: ProcessJsonResultType) -> Void
    public typealias ProcessJsonResult        = (forced: Bool, loadedJson: JSON, completion: ProcessJsonResultClosure) -> Void
    
    public var processJsonClosure: ProcessJsonResult?
    
    /**
     Processes data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completion: Closure called when operation finished
     */
    private func processData(forced forced: Bool, loadedData: NSData, completion: LoadResultClosure?) {
        var error: NSError?
        let json = JSON(data: loadedData, error: &error)
        if let error = error {
            completion?(result: Result.Failure(error))
        } else if let processJsonClosure = self.processJsonClosure {
            processJsonClosure(forced: forced, loadedJson: json) { (result) -> Void in
                switch result {
                case .Success(let processedData):
                    completion?(result: Result.Success(processedData))
                case .Failure(let error):
                    completion?(result: Result.Failure(error))
                }
            }
        } else if let processedData = loadedData as? T {
            completion?(result: Result.Success(processedData))
        } else {
            print(owner: "LoadAction[JSON]", items: "ProcessClosure not defined when return type is different than JSON", level: .Error)
            completion?(result: Result.Failure(NSError(domain: "LoadAction[JSON]", code: 837, description: "ProcessClosure not defined when return type is different than JSON")))
        }
    }
    
    /**
     Quick initializer with all closures
     
     - parameter load: Closure to load from web, must call result closure when finished
     - parameter delegates: Array containing objects that react to updated data
     */
    public init(
        urlRequest: UrlRequestResult,
        process:    ProcessJsonResult,
        delegates:  [LoadActionDelegate] = [],
        dummy:      (() -> ())? = nil)
    {
        self.processJsonClosure = process
        super.init(
            urlRequest: urlRequest,
            process: {  _,_,_ in },
            delegates:  delegates
        )
        processDataClosure = { (forced, loadedData, result) -> Void in
            self.processData(forced: forced, loadedData: loadedData, completion: result)
        }
    }
}

