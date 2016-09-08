//
//  FileLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 10/8/16.
//
//

import Foundation

public class ProcessFileLoadAction<T>: ProcessLoadAction<NSData, T> {
    
    public init(
        filePath:   FileLoadAction.FilePathResult,
        process:    ProcessResult,
        dummy:      (() -> ())? = nil)
    {
        super.init(
            baseLoadAction: FileLoadAction(filePath: filePath),
            process:   process
        )
    }
    
}


public class FileLoadAction: LoadAction<NSData> {
    
    public typealias FilePathResultType    = Result<String, ErrorType>
    public typealias FilePathResultClosure = (result: FilePathResultType) -> Void
    public typealias FilePathResult        = (completion: FilePathResultClosure) -> Void
    
    public var filePathClosure:  FilePathResult
    
    private func loadInner(completion completion: LoadResultClosure) {
        filePathClosure() { (result) -> Void in
            switch result {
            case .Failure(let error):
                completion(result: .Failure(error))
            case .Success(let filePath):
                let fullFilePath = "\(NSHomeDirectory())/Documents/\(filePath)"
                print(owner: "LoadAction[File]", items: "FilePath: \(fullFilePath)", level: .Info)
                guard let loadedData = NSData(contentsOfFile: fullFilePath) else {
                    let error = NSError(domain: "LoadAction[File]", code: 421, description: "Archivo no pudo ser leido")
                    completion(result: .Failure(error))
                    return
                }
                completion(result: .Success(loadedData))
            }
        }
    }
    
    public init(
        filePath:   FilePathResult,
        dummy:      (() -> ())? = nil)
    {
        self.filePathClosure  = filePath
        super.init(
            load: { _ in }
        )
        loadClosure = { (result) -> Void in
            self.loadInner(completion: result)
        }
    }
    
}

public extension FileLoadAction {
    
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
