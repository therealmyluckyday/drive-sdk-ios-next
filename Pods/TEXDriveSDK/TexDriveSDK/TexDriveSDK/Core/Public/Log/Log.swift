//
//  Log.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 05/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

protocol LogProtocol {
    static func configure(regex: NSRegularExpression, logType: LogType)
    static func configure(logger: LogImplementation)
}

protocol LogImplementation {
    func print(_ description: String, type: LogType, fileName: String, functionName: String)
    func configure(regex: NSRegularExpression, logType: LogType)
}

extension LogImplementation {
    func warning(_ description: String, fileName: String, functionName: String) {
        print(description, type: LogType.Warning, fileName: fileName, functionName: functionName)
    }
    
    func error(_ description: String, fileName: String, functionName: String) {
        print(description, type: LogType.Error, fileName: fileName, functionName: functionName)
    }
}

class Log: LogProtocol {
    // MARK: Property
    private static var _log: LogImplementation?
    
    // MARK: LogProtocol Method
    static func configure(regex: NSRegularExpression, logType: LogType) {
        _log?.configure(regex: regex, logType: logType)
    }
    
    static func print(_ description: String, type: LogType = .Info, fileName: String = #file, functionName: String = #function) {
            _log?.print(description, type: type, fileName: fileName, functionName: functionName)
    }
    static func configure(logger: LogImplementation) {
        _log = logger
    }
}
