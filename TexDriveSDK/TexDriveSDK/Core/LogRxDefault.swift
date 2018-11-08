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
    let file: String
    
    // Lifecycle method
    init(rxLog: PublishSubject<LogDetail>, currentFile: String) {
        file = currentFile
        super.init(rxLog: rxLog)
    }
    
    // MARK: LogImplementation Protocol
    func print(_ description: String, type: LogType = .Info, function: String? = nil) {
        super.print(description, type: type, file: file, function: function)
    }
}
