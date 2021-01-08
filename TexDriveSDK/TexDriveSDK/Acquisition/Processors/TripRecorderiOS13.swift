//
//  TripRecorderiOS13.swift
//  TexDriveSDK
//
//  Created by A944VQ on 15/12/2020.
//  Copyright © 2020 Axa. All rights reserved.
//


#if canImport(Swiftui)
import Foundation
import SwiftUI

@available(iOS 13.0, *)
public class TripRecorderiOS13SwiftUI: TripRecorder, ObservableObject {
    @Published var tripProgress: TripProgress?
    @Published var isRecordingiOS13     = false
    
    public override func start(date: Date = Date()) {
        
        isRecordingiOS13 = true
    }
    
    public override func stop() {
        
        isRecordingiOS13 = false
    }
    
    override func update(tripProgress: TripProgress) {
            self.tripProgress = tripProgress
    }
    /* TexServiceiOS13
    @Published var log                  : LogMessage?
    
    // MARK: - Log Management
    func configureLog(_ log: PublishSubject<LogMessage>) {
        guard let services = texServices else { return }
        log.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in
            if let logDetail = event.element {
                self?.report(logDetail: logDetail)
            }
            }.disposed(by: self.rxDisposeBag)
        
        do {
            let regex = try NSRegularExpression(pattern: ".*(TripChunk|Score|URLRequestExtension.swift|API|State).*", options: NSRegularExpression.Options.caseInsensitive)
//            let regex = try NSRegularExpression(pattern: ".*.*", options: NSRegularExpression.Options.caseInsensitive)
            services.logManager.log(regex: regex, logType: LogType.Info)
        } catch {
            let customLog = OSLog(subsystem: "fr.axa.tex", category: #file)
            os_log("[ViewController][configureLog] regex error %@", log: customLog, type: .error, error.localizedDescription)
        }
    }*/
}

#endif
