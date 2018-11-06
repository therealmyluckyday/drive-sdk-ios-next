//
//  Log.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 05/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

struct LogDetail {
    let type: LogType
    let description: String
    let file: String
}

enum LogType: Int {
    case Error = 0
    case Warning = 1
    case Info = 2
}

protocol LogProtocol {
    static func configure(regex: NSRegularExpression, logType: LogType)
    static func Print(_ description: String, type: LogType, file: String, function: String?)
}

protocol LogImplementation {
    func configure(regex: NSRegularExpression, logType: LogType)
    func Print(_ description: String, type: LogType, file: String)
}

public class Log: LogProtocol {
    // MARK: Property
    private static let _log = LogRx()
    
    // MARK: LogProtocol Method
    static func Print(_ description: String, type: LogType = .Info, file: String, function: String? = nil) {
        var log = ""
        if let function = function {
            log += "[\(function)]"
        }
        log += description
        _log.Print(log, type: type, file: file)
    }
    
    static func configure(regex: NSRegularExpression, logType: LogType) {
        _log.configure(regex: regex, logType: logType)
    }
}

