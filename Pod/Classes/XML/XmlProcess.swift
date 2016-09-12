//
//  XmlProcess.swift
//  ULima
//
//  Created by Gabriel Lanata on 29/6/16.
//  Copyright © 2016 Universidad de Lima. All rights reserved.
//

import Foundation
import AEXML

public func XmlProcess(loadedValue: NSData) throws -> AEXMLDocument {
    return try AEXMLDocument(xmlData: loadedValue)
}