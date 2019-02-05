//
//  LogDetail.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 07/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

public enum LogType: Int {
    case Error = 0
    case Warning = 1
    case Info = 2
}

public class LogMessage: CustomStringConvertible {
    // MARK: Property
    public let type: LogType
    public let message: String
    public let fileName: String
    public let functionName: String
    public let date = Date()
    private static let dateFormatter = ISO8601DateFormatter()
    
    // MARK: Lifecycle
    init(type currentType: LogType, detail description: String, fileName fileWithPath: String, functionName currentFunction: String) {
        type = currentType
        message = description
        functionName = currentFunction
        fileName = LogMessage.cleanPathForFile(fileWithPath: fileWithPath)
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
    public var description: String {
        let dateString = LogMessage.dateFormatter.string(from: date)
        return "[\(dateString)][\(fileName)][\(functionName)]\(message)"
    }
}

