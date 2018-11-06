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
    var rules = [NSRegularExpression: LogType]()
    var rx_log = PublishSubject<LogDetail>()
    var rx_disposeBag = DisposeBag()
    
    // MARK: LogImplementation Protocol
    func Print(_ description: String, type: LogType = .Info, file: String) {
        self.rx_log.onNext(LogDetail(type: type, description: description, file: file))
    }
    
    func configure(regex: NSRegularExpression, logType: LogType) {
        self.rules[regex] = logType
        self.rx_log.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in    
            if let logDetail = event.element, let fileSubstring = logDetail.file.split(separator: "/").last {
                let file = String(fileSubstring)
                let results = regex.matches(in: file, options:NSRegularExpression.MatchingOptions.anchored, range: NSRange(location: 0, length: file.count))
                if results.count > 0 && logType.rawValue >= logDetail.type.rawValue {
                    self?.report(description: "[\(file)]\(logDetail.description)")
                }
            }
            }.disposed(by: self.rx_disposeBag)
    }
    
    func report(description: String) {
        print(description)
    }
}
