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
    func print(_ description: String, type: LogType = .Info, fileName: String = #file, functionName: String = #function) {
        let logDetail = LogDetail(type: type, detail: description, fileName: fileName, functionName: functionName)
        self.rx_log.onNext(logDetail)
    }
    
    func warning(_ description: String, fileName: String = #file, functionName: String = #function) {
        self.print(description, type: LogType.Warning, fileName: fileName, functionName: functionName)
    }
    
    func error(_ description: String, fileName: String = #file, functionName: String = #function) {
        self.print(description, type: LogType.Error, fileName: fileName, functionName: functionName)
    }
}
