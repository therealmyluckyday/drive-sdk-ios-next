//
//  LogRxFactory.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 06/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift
import os
import OSLog

class LogRx: LogImplementation {
    
    // MARK: Property
    private let rxLog = PublishSubject<LogMessage>()
    private var rules = [NSRegularExpression: LogType]()
    private let rxDisposeBag = DisposeBag()
    private var isTesting: Bool = false
    let rxLogOutput = PublishSubject<LogMessage>()
    
    // MARK: LogFactory protocol
    func configure(regex: NSRegularExpression, logType: LogType, isTesting: Bool) {
        self.isTesting = isTesting
        self.rules[regex] = logType
        self.rxLog.asObservable().subscribe { [weak self](event) in
            if let logDetail = event.element {
                if logDetail.canLog(regex: regex, logType: logType) {
                    self?.report(logDetail: logDetail)
                }
            }
            }.disposed(by: self.rxDisposeBag)
    }
    
    func report(logDetail: LogMessage) {
        rxLogOutput.onNext(logDetail)
    }
    
    
    func osLog(logDetail: LogMessage) {
        let detail =  logDetail.description
        switch logDetail.type.rawValue {
        case 0..<2:
            os_log("%{public}@" , log: OSLog.texDriveSDK, type: OSLogType.error, detail)
        default:
            os_log("%{public}@" , log: OSLog.texDriveSDK, type: OSLogType.debug, detail)
        }
    }
    
    // MARK: LogImplementation Protocol
    func print(_ description: String, type: LogType = .Info, fileName: String = #file, functionName: String = #function) {
        let logDetail = LogMessage(type: type, detail: description, fileName: fileName, functionName: functionName)
        #if targetEnvironment(simulator)
        self.osLog(logDetail: logDetail)
        if (type != .Info || isTesting) {
            //self.report(logDetail: logDetail)
            self.rxLog.onNext(logDetail)
        }
        #else
        self.rxLog.onNext(logDetail)
        #endif
    }
    
    func warning(_ description: String, fileName: String = #file, functionName: String = #function) {
        self.print(description, type: LogType.Warning, fileName: fileName, functionName: functionName)
    }
    
    func error(_ description: String, fileName: String = #file, functionName: String = #function) {
        self.print(description, type: LogType.Error, fileName: fileName, functionName: functionName)
    }
}
