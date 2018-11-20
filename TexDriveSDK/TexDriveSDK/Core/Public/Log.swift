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
    static func configure(loggerFactory: LogFactory)
}

protocol LogImplementation {
    func print(_ description: String, type: LogType, fileName: String, functionName: String)
    func warning(_ description: String, fileName: String, functionName: String)
    func error(_ description: String, fileName: String, functionName: String)
}

protocol LogDefaultImplementation: LogImplementation{
        var fileName: String { get }
        func print(_ description: String, type: LogType, functionName: String)
}

protocol LogFactory {
    var mainLogger: LogImplementation { get }
    func getLogger(file: String) -> LogDefaultImplementation
    func configure(regex: NSRegularExpression, logType: LogType)
}

class Log: LogProtocol {
    // MARK: Property
    private static var _log: LogFactory?
    
    // MARK: LogProtocol Method
    static func configure(regex: NSRegularExpression, logType: LogType) {
        _log?.configure(regex: regex, logType: logType)
    }
    
    static func print(_ description: String, type: LogType = .Info, fileName: String = #file, functionName: String = #function) {
            _log?.mainLogger.print(description, type: type, fileName: fileName, functionName: functionName)
    }
    static func configure(loggerFactory: LogFactory) {
        _log = loggerFactory
    }
}
