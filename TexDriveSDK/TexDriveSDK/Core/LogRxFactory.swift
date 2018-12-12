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

class LogRxFactory: LogFactory {
    // MARK: Property
    private var rxLog = PublishSubject<LogMessage>()
    private var rules = [NSRegularExpression: LogType]()
    private var rxDisposeBag = DisposeBag()
    lazy var mainLogger: LogImplementation =  {
        return LogRx(logMessage: rxLog)
    }()
    
    let rxLogOutput = PublishSubject<LogMessage>()
    
    // MARK: LogFactory protocol
    func getLogger(file: String) -> LogDefaultImplementation {
        return LogRxDefault(rxLog: rxLog, currentFile: file)
    }

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
        rxLogOutput.onNext(logDetail)
    }
}
