//
//  WebLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 2/10/16.
//
//

import Foundation

let session = URLSession(
    configuration: URLSessionConfiguration.default,
    delegate: nil,
    delegateQueue: OperationQueue.main
)

open class ProcessWebLoadAction<T>: ProcessLoadAction<Data, T> {
    
    public init(
        urlRequest: URLRequest,
        process:    @escaping ProcessResult,
        dummy:      (() -> ())? = nil)
    {
        super.init(
            baseLoadAction: WebLoadAction(urlRequest: urlRequest),
            process: process
        )
    }
    
}

open class WebLoadAction: LoadAction<Data> {
    
    open var urlRequest: URLRequest
    
    fileprivate func loadInner(completion: @escaping LoadResultClosure) {
        print(owner: "LoadAction[Web]", items: "Load Began (Url: \(urlRequest.url?.absoluteString ?? "-"))", level: .verbose)
        session.dataTask(with: urlRequest, completionHandler: { (loadedData, urlResponse, error) -> Void in
            if let error = error {
                var newError = error as NSError
                switch newError.code {
                case -1001, -1003, -1009:
                    newError = NSError(domain: "LoadAction[Web]", code: newError.code, description: "No hay conexión a internet")
                default: ()
                }
                print(owner: "LoadAction[Web]", items: "Load Failure, \(newError.localizedDescription) (Url: \(self.urlRequest.url?.absoluteString ?? "-"))", level: .error)
                completion(.failure(newError))
                return
            }
            guard let loadedData = loadedData else {
                print(owner: "LoadAction[Web]", items: "Load Failure, empty response (Url: \(self.urlRequest.url?.absoluteString ?? "-"))", level: .error)
                let error = NSError(domain: "LoadAction[Web]", code: 33, description: "Data retornada vacía")
                completion(.failure(error))
                return
            }
            print(owner: "LoadAction[Web]", items: "Load Success (Url: \(self.urlRequest.url?.absoluteString ?? "-"))", level: .verbose)
            completion(.success(loadedData))
        }).resume()
    }
    
    public init(urlRequest: URLRequest) {
        self.urlRequest  = urlRequest
        super.init(
            load: { _ in }
        )
        loadClosure = { (result) -> Void in
            self.loadInner(completion: result)
        }
    }
    
    public convenience init(url: URL) {
        self.init(urlRequest: URLRequest(url: url))
    }
    
}






