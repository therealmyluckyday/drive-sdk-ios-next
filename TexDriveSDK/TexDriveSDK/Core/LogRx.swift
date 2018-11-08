//
//  LogRx.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 05/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift

class LogRx: LogImplementation {
    // MARK: Property
    private let rx_log: PublishSubject<LogDetail>
    
    // Lifecycle method
    init(rxLog: PublishSubject<LogDetail>) {
        rx_log = rxLog
    }
    
    // MARK: LogImplementation Protocol
    func print(_ description: String, type: LogType = .Info, file: String, function: String? = nil) {
        let logDetail = LogDetail(type: type, detail: description, file: file, function: function)
        self.rx_log.onNext(logDetail)
    }
}
