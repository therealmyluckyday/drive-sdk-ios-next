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
    private var rx_log = PublishSubject<LogDetail>()
    private var rules = [NSRegularExpression: LogType]()
    private var rx_disposeBag = DisposeBag()
    lazy var mainLogger: LogImplementation =  {
        return LogRx(rxLog: rx_log)
    }()
    
    let rx_logOutput = PublishSubject<LogDetail>()
    
    // MARK: LogFactory protocol
    func getLogger(file: String) -> LogDefaultImplementation {
        return LogRxDefault(rxLog: rx_log, currentFile: file)
    }

    func configure(regex: NSRegularExpression, logType: LogType) {
        self.rules[regex] = logType
        self.rx_log.asObservable().subscribe { [weak self](event) in
            if let logDetail = event.element {
                if logDetail.canLog(regex: regex, logType: logType) {
                    self?.report(logDetail: logDetail)
                }
            }
            }.disposed(by: self.rx_disposeBag)
    }
    
    func report(logDetail: LogDetail) {
        rx_logOutput.onNext(logDetail)
    }
}
