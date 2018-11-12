//
//  LogDetail.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 07/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

enum LogType: Int {
    case Error = 0
    case Warning = 1
    case Info = 2
}

class LogDetail: CustomStringConvertible {
    // MARK: Property
    let type: LogType
    let detail: String
    let fileName: String
    let functionName: String?
    
    // MARK: Lifecycle
    init(type currentType: LogType, detail description: String, fileName fileWithPath: String, functionName currentFunction: String?) {
        type = currentType
        detail = description
        functionName = currentFunction
        fileName = LogDetail.cleanPathForFile(fileWithPath: fileWithPath)
    }
    
    // MARK: Method
    class func cleanPathForFile(fileWithPath: String) -> String {
        if let fileSubstring = fileWithPath.split(separator: "/").last {
            return String(fileSubstring)
        }
        return fileWithPath
    }
    
    func canLog(regex: NSRegularExpression, logType: LogType) -> Bool {
        let results = regex.matches(in: fileName, options:NSRegularExpression.MatchingOptions.anchored, range: NSRange(location: 0, length: fileName.count))
        return results.count > 0 && logType.rawValue >= self.type.rawValue
    }
    
    // MARK: CustomStringConvertible protocol
    var description: String {
        if let function = functionName {
            return "[\(fileName)][\(function)]\(detail)"
        }
        return "[\(fileName)]\(detail)"
    }
}

