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
        print(owner: "LoadAction[File]", items: "Load Began (\(fullFilePath))", level: .Debug)
        guard let loadedData = NSData(contentsOfFile: fullFilePath) else {
            print(owner: "LoadAction[File]", items: "Load Failure", level: .Error)
            let error = NSError(domain: "LoadAction[File]", code: 421, description: "Archivo no pudo ser leido")
            completion(result: .Failure(error))
            return
        }
        print(owner: "LoadAction[File]", items: "Load Success", level: .Debug)
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
    
    public class func saveToFile(filePath filePath: String, value: NSData) throws {
        let fullFilePath = "\(NSHomeDirectory())/Documents/\(filePath)"
        print(owner: "LoadAction[File]", items: "Save Began (\(fullFilePath))", level: .Debug)
        guard value.writeToFile(fullFilePath, atomically: true) == true else {
            print(owner: "LoadAction[File]", items: "Save Failure", level: .Error)
            throw NSError(domain: "LoadAction[File]", code: 422, description: "Archivo no pudo ser guardado")
        }
        print(owner: "LoadAction[File]", items: "Save Success", level: .Debug)
    }
    
}
