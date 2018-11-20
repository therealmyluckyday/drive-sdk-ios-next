//
//  ViewController.swift
//  TexDriveApp
//
//  Created by Axa on 11/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import UIKit
import CoreLocation
import TexDriveSDK
import CallKit
import CoreMotion
import Crashlytics
import RxSwift
import os

class ViewController: UIViewController {
    @IBOutlet weak var TripSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var logTextField: UITextView!
    @IBOutlet weak var textfield: UITextField!
    var tripRecorder : TripRecorder?
    var locationManager = CLLocationManager()
    let rx_disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TripSegmentedControl.selectedSegmentIndex = 1
        locationManager.requestAlwaysAuthorization()
    }
    
    @IBAction func tripSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            tripRecorder?.stop()
            launchTracking()
            tripRecorder?.start()
            break
        default:
            tripRecorder?.stop()
        }
    }
    
    func launchTracking()  {
        var user = User.Anonymous
        
        if let userName = textfield.text {
            user = User.Authentified(userName)
            self.logUser(userName: userName)
        }
        
        do {
            if let configuration = try Config(applicationId: "APP-TEST", applicationLocale: Locale.current, currentUser: user, currentMode: Mode.manual) {
                tripRecorder = TripRecorder(config: configuration)
                configureLog(configuration.rx_log)
                do {
                    let regex = try NSRegularExpression(pattern: ".*.*", options: NSRegularExpression.Options.caseInsensitive)
                    configuration.log(regex: regex, logType: LogType.Info)
                } catch {
                    let customLog = OSLog(subsystem: "fr.axa.tex", category: #file)
                    os_log("-------------REGEX ERROR--------------- %@", log: customLog, type: .error, error.localizedDescription)
                }
            }
        } catch ConfigurationError.LocationNotDetermined(let description) {
            print(description)
        } catch {
            print("\(error)")
        }
    }
    
    func configureLog(_ log: PublishSubject<LogDetail>) {
        log.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in
            if let logDetail = event.element {
                self?.report(logDetail: logDetail)
            }
            }.disposed(by: self.rx_disposeBag)
        
    }
    
    func report(logDetail: LogDetail) {
        let customLog = OSLog(subsystem: "fr.axa.tex", category: logDetail.fileName)
        
        switch logDetail.type {
        case .Info:
            Answers.logCustomEvent(withName: logDetail.functionName,
                                           customAttributes: [
                                            "filename" : logDetail.fileName,
                                            "functionName": logDetail.functionName,
                                            "type": "Info",
                                            "detail": logDetail.detail
                ])
            os_log("%@", log: customLog, type: .info, logDetail.description)
            break
        case .Warning:
            Crashlytics.sharedInstance().recordError(NSError(domain: logDetail.fileName, code: 1111, userInfo: ["filename" : logDetail.fileName, "functionName": logDetail.functionName, "description": logDetail.detail]))
            os_log("%@", log: customLog, type: .debug, logDetail.description)
            break
        case .Error:
            os_log("%@", log: customLog, type: .error, logDetail.description)
            Crashlytics.sharedInstance().recordError(NSError(domain: logDetail.fileName, code: 9999, userInfo: ["filename" : logDetail.fileName, "functionName": logDetail.functionName, "description": logDetail.detail]))
            break
        }
        let oldLog = self.logTextField.text ?? ""
        let newLog = String(describing:logDetail.description)
        let text = "\(oldLog)\n\(newLog)"
        print("oldLog"+oldLog)
        print("newLog"+newLog)
        self.logTextField.text = text
        
        print(text)
    }
    
    func logUser(userName: String) {
        Crashlytics.sharedInstance().setUserIdentifier(userName)
        Crashlytics.sharedInstance().setUserName(userName)
    }
}


