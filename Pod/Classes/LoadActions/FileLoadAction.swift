//
//  FileLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 10/8/16.
//
//

import Foundation

open class ProcessFileLoadAction<T>: ProcessLoadAction<Data, T> {
    
    public init(
        filePath: String,
        process:  @escaping ProcessResult,
        dummy:    (() -> ())? = nil)
    {
        super.init(
            baseLoadAction: FileLoadAction(filePath: filePath),
            process: process
        )
    }
    
}


open class FileLoadAction: LoadAction<Data> {
    
    open var filePath: String
    
    fileprivate func loadInner(completion: LoadResultClosure) {
        let fullFilePath = "\(NSHomeDirectory())/Documents/\(filePath)"
        print(owner: "LoadAction[File]", items: "Load Began (\(fullFilePath))", level: .debug)
        guard let loadedData = try? Data(contentsOf: URL(fileURLWithPath: fullFilePath)) else {
            print(owner: "LoadAction[File]", items: "Load Failure", level: .error)
            let error = NSError(domain: "LoadAction[File]", code: 421, description: "Archivo no pudo ser leido")
            completion(.failure(error))
            return
        }
        print(owner: "LoadAction[File]", items: "Load Success", level: .debug)
        completion(.success(loadedData))
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
    
    public class func saveToFile(filePath: String, value: Data) throws {
        let fullFilePath = "\(NSHomeDirectory())/Documents/\(filePath)"
        print(owner: "LoadAction[File]", items: "Save Began (\(fullFilePath))", level: .debug)
        guard ((try? value.write(to: URL(fileURLWithPath: fullFilePath), options: [.atomic])) != nil) == true else {
            print(owner: "LoadAction[File]", items: "Save Failure", level: .error)
            throw NSError(domain: "LoadAction[File]", code: 422, description: "Archivo no pudo ser guardado")
        }
        print(owner: "LoadAction[File]", items: "Save Success", level: .debug)
    }
    
}
