//
//  Log.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 05/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

protocol LogProtocol {
    static func defaultLogger(file: String) -> LogDefaultImplementation
    static func configure(regex: NSRegularExpression, logType: LogType)
    static func configure(loggerFactory: LogFactory)
}

protocol LogImplementation {
    func print(_ description: String, type: LogType, file: String, function: String)
}

protocol LogDefaultImplementation: LogImplementation{
        var file: String { get }
        func print(_ description: String, type: LogType, function: String)
}

protocol LogFactory {
    var mainLogger: LogImplementation { get }
    func getLogger(file: String) -> LogDefaultImplementation
    func configure(regex: NSRegularExpression, logType: LogType)
}

public class Log: LogProtocol {
    // MARK: Property
    private static var _log: LogFactory = LogRxFactory()
    
    // MARK: LogProtocol Method
    static func configure(regex: NSRegularExpression, logType: LogType) {
        _log.configure(regex: regex, logType: logType)
    }
    
    static func print(_ description: String, type: LogType = .Info, file: String = #file, function: String = #function) {
            _log.mainLogger.print(description, type: type, file: file, function: function)
    }
    static func configure(loggerFactory: LogFactory) {
        _log = loggerFactory
    }
    
    static func defaultLogger(file: String) -> LogDefaultImplementation {
        return _log.getLogger(file: file)
    }
}
