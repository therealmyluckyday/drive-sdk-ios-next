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
    let rxLogOutput = PublishSubject<LogMessage>()
    
    // MARK: LogFactory protocol
    func configure(regex: NSRegularExpression, logType: LogType) {
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
        //rxLogOutput.onNext(logDetail)
        let detail =  logDetail.description
        switch logDetail.type.rawValue {
        case 0..<2:
            os_log("%{public}@" , log: OSLog.texDriveSDK, type: OSLogType.error, detail)
            rxLogOutput.onNext(logDetail)
        default:
            os_log("%{public}@" , log: OSLog.texDriveSDK, type: OSLogType.info, detail)
        }
        
    }
    
    // MARK: LogImplementation Protocol
    func print(_ description: String, type: LogType = .Info, fileName: String = #file, functionName: String = #function) {
        let logDetail = LogMessage(type: type, detail: description, fileName: fileName, functionName: functionName)
        //self.rxLog.onNext(logDetail)
        self.report(logDetail: logDetail)
    }
    
    func warning(_ description: String, fileName: String = #file, functionName: String = #function) {
        self.print(description, type: LogType.Warning, fileName: fileName, functionName: functionName)
    }
    
    func error(_ description: String, fileName: String = #file, functionName: String = #function) {
        self.print(description, type: LogType.Error, fileName: fileName, functionName: functionName)
    }
}
