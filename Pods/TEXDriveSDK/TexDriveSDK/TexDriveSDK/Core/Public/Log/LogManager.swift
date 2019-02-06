//
//  LogManager.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 01/02/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift

public protocol LogConfiguration {
    var rxLog: PublishSubject<LogMessage> { get }
    func log(regex: NSRegularExpression, logType: LogType)
}

public class LogManager: LogConfiguration {
    // MARK: - Property
    // MARK: LogConfiguration
    public var rxLog: PublishSubject<LogMessage> {
        get {
            return logFactory.rxLogOutput
        }
    }
    
    let logFactory = LogRx()
    
    // MARK: - Lifecycle
    init() {
        Log.configure(logger: logFactory)
    }
    
    // MARK: - LogConfiguration
    public func log(regex: NSRegularExpression, logType: LogType) {
        Log.configure(regex: regex, logType: logType)
    }
}
