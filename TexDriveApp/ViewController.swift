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
    
    @IBOutlet weak var scoreButton: UIButton!
    @IBOutlet weak var logTextField: UITextView!
    @IBOutlet weak var textfield: UITextField!
    
    
    
    var tripRecorder : TripRecorder?
    var locationManager = CLLocationManager()
    let rx_disposeBag = DisposeBag()
    let rxScore = PublishSubject<Score>()
    var currentTripId : String?
    var texServices: TexServices?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreButton.alpha = 0
        TripSegmentedControl.selectedSegmentIndex = 1
        locationManager.requestAlwaysAuthorization()
        textfield.text = "Erwan-ios12"
        rxScore.asObserver().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
            let score = event.event
            self.appendText(string: "SCORE: \(score)")
            
        }.disposed(by: rx_disposeBag)
    }
    
    @IBAction func tripSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            startTrip()
            break
        default:
            stopTrip()
        }
    }
    
    func startTrip() {
        tripRecorder?.stop()
        launchTracking()
        tripRecorder?.start()
    }
    
    func stopTrip() {
        tripRecorder?.stop()
        UIView.animate(withDuration: 0.3, delay: 26, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.scoreButton.alpha = 1
        }) { (finished) in
        
        }
    }
    
    @IBAction func getScore(_ sender: Any) {
        UIView.animate(withDuration: 0.6, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.scoreButton.alpha = 0
        }) { (finished) in
            
        }

        texServices!.scoringClient.getScore(tripId: "461105AE-A712-41A7-939C-4982413BE30F1543910782.13927", rxScore: rxScore)
    }
    
    func launchTracking()  {
        var user = User.Anonymous
        
        if let userName = textfield.text {
            user = User.Authentified(userName)
            self.logUser(userName: userName)
        }
        
        do {
            if let configuration = try Config(applicationId: "youdrive_france_prospect", applicationLocale: Locale.current, currentUser: user, currentMode: Mode.manual) {
                texServices = TexServices(configuration:configuration)
                tripRecorder = texServices!.tripRecorder
                configureLog(configuration.rx_log)
                do {
                    let regex = try NSRegularExpression(pattern: ".*.*", options: NSRegularExpression.Options.caseInsensitive)
                    configuration.log(regex: regex, logType: LogType.Error)
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
    
    func configureLog(_ log: PublishSubject<LogMessage>) {
        log.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in
            if let logDetail = event.element {
                self?.report(logDetail: logDetail)
            }
            }.disposed(by: self.rx_disposeBag)
        
    }
    
    func report(logDetail: LogMessage) {
        let customLog = OSLog(subsystem: "fr.axa.tex", category: logDetail.fileName)
        print(logDetail.description)
        switch logDetail.type {
        case .Info:
            Answers.logCustomEvent(withName: logDetail.functionName,
                                           customAttributes: [
                                            "filename" : logDetail.fileName,
                                            "functionName": logDetail.functionName,
                                            "type": "Info",
                                            "detail": logDetail.message
                ])
            os_log("%@", log: customLog, type: .info, logDetail.description)
            break
        case .Warning:
            Crashlytics.sharedInstance().recordError(NSError(domain: logDetail.fileName, code: 1111, userInfo: ["filename" : logDetail.fileName, "functionName": logDetail.functionName, "description": logDetail.message]))
            os_log("%@", log: customLog, type: .debug, logDetail.description)
            break
        case .Error:
            os_log("%@", log: customLog, type: .error, logDetail.description)
            Crashlytics.sharedInstance().recordError(NSError(domain: logDetail.fileName, code: 9999, userInfo: ["filename" : logDetail.fileName, "functionName": logDetail.functionName, "description": logDetail.message]))
            break
        }

        let newLog = String(describing:logDetail.description)
        self.appendText(string: newLog)
    }
    
    func appendText(string: String) {
        let oldLog = self.logTextField.text ?? ""
        let text = "\(oldLog)\n\(string)"
        self.logTextField.text = text
    }
    
    func logUser(userName: String) {
        Crashlytics.sharedInstance().setUserIdentifier(userName)
        Crashlytics.sharedInstance().setUserName(userName)
    }
}


