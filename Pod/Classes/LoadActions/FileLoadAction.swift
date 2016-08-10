//
//  FileLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 10/8/16.
//
//

import Foundation

public class FileLoadAction<F>: ProcessLoadAction<NSData, F> {
    
    public typealias FilePathResultType    = Result<String, ErrorType>
    public typealias FilePathResultClosure = (result: FilePathResultType) -> Void
    public typealias FilePathResult        = (completion: FilePathResultClosure) -> Void
    
    public var filePathClosure:  FilePathResult
    
    /**
     Loads data giving the option of paging or loading new.
     
     - parameter forced: If true forces main load
     - parameter completion: Closure called when operation finished
     */
    private func loadRawInner(completion completion: LoadRawResultClosure) {
        filePathClosure() { (result) -> Void in
            switch result {
            case .Failure(let error):
                completion(result: .Failure(error))
            case .Success(let filePath):
                let fullFilePath = "\(NSHomeDirectory())/Documents/\(filePath)"
                print(owner: "LoadAction[File]", items: "Loading from filePath", fullFilePath, level: .Info)
                guard let loadedData = NSData(contentsOfFile: fullFilePath) else {
                    let error = NSError(domain: "LoadAction[File]", code: 421, description: "Archivo no pudo ser leido")
                    completion(result: .Failure(error))
                    return
                }
                completion(result: .Success(loadedData))
            }
        }
    }
    
    /**
     Quick initializer with all closures
     
     - parameter load: Closure to load from web, must call result closure when finished
     - parameter delegates: Array containing objects that react to updated data
     */
    public init(
        filePath:   FilePathResult,
        process:    ProcessResult? = nil,
        delegates:  [LoadActionDelegate] = [],
        dummy:      (() -> ())? = nil)
    {
        self.filePathClosure  = filePath
        super.init(
            loadRaw:   { _ in },
            process:   process,
            delegates: delegates
        )
        loadRawClosure = { (result) -> Void in
            self.loadRawInner(completion: result)
        }
    }
    
    
    
    public typealias FileSaveResultType    = Result<Bool, ErrorType>
    public typealias FileSaveResultClosure = (result: FileSaveResultType) -> Void
    public typealias FileSaveResult        = (completion: FileSaveResultClosure) -> Void
    
    public class func saveToFile(filePath filePathClosure: FilePathResult, value: NSData, completion: FileSaveResultClosure) {
        filePathClosure() { (result) -> Void in
            switch result {
            case .Failure(let error):
                completion(result: .Failure(error))
            case .Success(let filePath):
                let fullFilePath = "\(NSHomeDirectory())/Documents/\(filePath)"
                print(owner: "LoadAction[File]", items: "Saving to filePath", fullFilePath, level: .Info)
                guard value.writeToFile(fullFilePath, atomically: true) == true else {
                    let error = NSError(domain: "LoadAction[File]", code: 422, description: "Archivo no pudo ser guardado")
                    completion(result: .Failure(error))
                    return
                }
                completion(result: .Success(true))
            }
        }
    }
    
}
