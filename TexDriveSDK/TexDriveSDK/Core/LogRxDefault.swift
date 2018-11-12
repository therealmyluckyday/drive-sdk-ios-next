//
//  LogRxDefault.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 07/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import RxSwift

class LogRxDefault: LogRx, LogDefaultImplementation {
    // MARK: Property
    let fileName: String
    
    // Lifecycle method
    init(rxLog: PublishSubject<LogDetail>, currentFile: String) {
        fileName = currentFile
        super.init(rxLog: rxLog)
    }
    
    // MARK: LogImplementation Protocol
    func print(_ description: String, type: LogType = .Info, functionName: String = #function) {
        super.print(description, type: type, fileName: fileName, functionName: functionName)
    }
}
