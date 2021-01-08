//
//  TexServicesiOS13.swift
//  TexDriveSDK
//
//  Created by A944VQ on 16/12/2020.
//  Copyright © 2020 Axa. All rights reserved.
//
#if canImport(Swiftui)
import Foundation
import OSLog
import RxSwift
import SwiftUI

@available(iOS 13.0, *)
public class TexServicesiOS13SwiftUI: TexServices, ObservableObject {
    @Published          var log                 : LogMessage?
    @LateInitialized    var tripRecorderiOS13   : TripRecorderiOS13SwiftUI
    
    private static let sharedInstance = TexServicesiOS13SwiftUI()
    
    
    // MARK: - Log Management
    func configureLog(_ log: PublishSubject<LogMessage>) {
        log.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in
            if let logDetail = event.element {
                self?.log = logDetail
            }
        }.disposed(by: self.disposeBag!)
        
        do {
            let regex = try NSRegularExpression(pattern: ".*(TripChunk|Score|URLRequestExtension.swift|API|State).*", options: NSRegularExpression.Options.caseInsensitive)
            self.logManager.log(regex: regex, logType: LogType.Info)
        } catch {
            let customLog = OSLog(subsystem: "fr.axa.tex", category: #file)
            os_log("[ViewController][configureLog] regex error %@", log: customLog, type: .error, error.localizedDescription)
        }
    }
    
    // MARK: - Public Method
    public override class func service(configuration: ConfigurationProtocol, isTesting: Bool = false) -> TexServices {
        if sharedInstance._tripRecorderiOS13.storage != nil {
            sharedInstance.tripRecorderiOS13.autoMode?.disable()
            sharedInstance.tripRecorderiOS13.stop()
        }
        sharedInstance.reconfigure(configuration, isTesting: isTesting)
        return sharedInstance
    }
    // MARK: - Internal Method
    internal override func reconfigure(_ configuration: ConfigurationProtocol, isTesting: Bool) {
        super.reconfigure(configuration, isTesting: isTesting)
        
        
        self.configureLog(logManager.rxLog)
    }
    
    
    internal override func configureTripRecorder(configuration: ConfigurationProtocol, sessionManager: APITripSessionManager) {
        let newTripRecorder = TripRecorderiOS13SwiftUI(configuration: configuration, sessionManager: sessionManager)
        self.tripRecorder = newTripRecorder
        self.tripRecorderiOS13 = newTripRecorder
    }
    
}

#endif

