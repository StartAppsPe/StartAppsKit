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
        filePath: String,
        process:  ProcessResult,
        dummy:    (() -> ())? = nil)
    {
        super.init(
            baseLoadAction: FileLoadAction(filePath: filePath),
            process: process
        )
    }
    
}


public class FileLoadAction: LoadAction<NSData> {
    
    public var filePath: String
    
    private func loadInner(completion completion: LoadResultClosure) {
        let fullFilePath = "\(NSHomeDirectory())/Documents/\(filePath)"
        print(owner: "LoadAction[File]", items: "FilePath: \(fullFilePath)", level: .Debug)
        guard let loadedData = NSData(contentsOfFile: fullFilePath) else {
            let error = NSError(domain: "LoadAction[File]", code: 421, description: "Archivo no pudo ser leido")
            completion(result: .Failure(error))
            return
        }
        completion(result: .Success(loadedData))
    }
    
    public init(
        filePath: String
        )
    {
        self.filePath  = filePath
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
    
    public class func saveToFile(filePath filePath: String, value: NSData, completion: FileSaveResultClosure) {
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
