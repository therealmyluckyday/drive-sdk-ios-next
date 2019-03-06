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

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var TripSegmentedControl: UISegmentedControl!
    @IBOutlet weak var scoreButton: UIButton!
    @IBOutlet weak var logTextField: UITextView!
    @IBOutlet weak var textfield: UITextField!
    
    var tripRecorder : TripRecorder?
    var locationManager = CLLocationManager()
    let rxDisposeBag = DisposeBag()
    lazy var currentTripId = { () -> TripId in
        if let tripId = tripRecorder?.currentTripId {
            return tripId
        }
        return TripId(uuidString: "165D217D-8339-4D73-9683-9C1AD3BF1B71")!
    }()
    var texServices: TexServices?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreButton.alpha = 1
        TripSegmentedControl.selectedSegmentIndex = 1
        locationManager.requestAlwaysAuthorization()
        let userId = "Erwan-"+UIDevice.current.systemName + UIDevice.current.systemVersion
        textfield.text = userId
        
        logTextField.isEditable = false
        CLLocationManager().requestAlwaysAuthorization()
        self.configureTexSDK(withUserId: userId)
    }
    
    func configureTexSDK(withUserId: String) {
        let user = User.Authentified(withUserId)
        self.logUser(userName: withUserId)
        do {
            if let configuration = try Config(applicationId: "APP-TEST", applicationLocale: Locale.current, currentUser: user) {
                texServices = TexServices.service(reconfigureWith: configuration)
                texServices!.tripRecorder.tripIdFinished.asObserver().observeOn(MainScheduler.asyncInstance).subscribe { [weak self] (event) in
                    if let tripId = event.element {
                        self?.appendText(string: "\n Trip finished: \n \(tripId.uuidString)")
                    }
                    }.disposed(by: rxDisposeBag)
                tripRecorder = texServices!.tripRecorder
                tripRecorder?.rxIsDriving.asObserver().observeOn(MainScheduler.asyncInstance).subscribe({ [weak self] (event) in
                    if let isDriving = event.element {
                        self?.appendText(string: "\n isDriving: \n \(isDriving)")
                        if isDriving {
                            self?.appendText(string: "\n SHOULD BE START: \n \(isDriving)")
                            self?.sendNotification("Start")
                            self?.TripSegmentedControl.selectedSegmentIndex = 0
                            
                        } else {
                            self?.appendText(string: "\n SHOULD BE STOP: \n \(isDriving)")
                            self?.sendNotification("Stop")
                            self?.TripSegmentedControl.selectedSegmentIndex = 1
                        }
                        self?.scoreButton.alpha = CGFloat((!isDriving).hashValue)
                        
                    }
                }).disposed(by: rxDisposeBag)
                
                texServices?.rxScore.asObserver().observeOn(MainScheduler.asyncInstance).retry().subscribe({ [weak self] (event) in
                    if let score = event.element {
                        self?.appendText(string: "NEW SCORE \(score)")
                    }
                }).disposed(by: rxDisposeBag)
                self.configureLog(texServices!.logManager.rxLog)
                tripRecorder?.activateAutoMode()
            }
        } catch ConfigurationError.LocationNotDetermined(let description) {
            print(description)
        } catch {
            print("\(error)")
        }
    }
    
    @IBAction func tripSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        textfield.resignFirstResponder()
        switch sender.selectedSegmentIndex {
        case 0:
            startTrip()
            break
        default:
            stopTrip()
        }
    }
    
    func startTrip() {
        tripRecorder?.activateAutoMode()
//        tripRecorder?.start()
    }
    
    func stopTrip() {
        tripRecorder?.disableAutoMode()
//        tripRecorder?.stop()
        showGetScoreButton()
    }
    
    func showGetScoreButton() {
        UIView.animate(withDuration: 0.3, delay: 26, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.scoreButton.alpha = 1
        }) { (finished) in
            
        }
    }
    
    func hideGetScoreButton() {
        UIView.animate(withDuration: 0.3, delay: 26, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.scoreButton.alpha = 0
        }) { (finished) in
            
        }
    }
    
    @IBAction func getScore(_ sender: Any) {
        UIView.animate(withDuration: 0.6, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.scoreButton.alpha = 0
        }) { (finished) in
            
        }
        if let rxScore = texServices?.rxScore {
            texServices?.scoreRetriever.getScore(tripId: currentTripId, rxScore: rxScore)
        }
    }
    
    // MARK: - Log Management
    func configureLog(_ log: PublishSubject<LogMessage>) {
        log.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in
            if let logDetail = event.element {
                self?.report(logDetail: logDetail)
            }
            }.disposed(by: self.rxDisposeBag)
        
        do {
            let regex = try NSRegularExpression(pattern: ".*.*", options: NSRegularExpression.Options.caseInsensitive)
            texServices?.logManager.log(regex: regex, logType: LogType.Error)
        } catch {
            let customLog = OSLog(subsystem: "fr.axa.tex", category: #file)
            os_log("[ViewController][configureLog] regex error %@", log: customLog, type: .error, error.localizedDescription)
        }
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
    
    // MARK: - Crashlytics setup
    func logUser(userName: String) {
        Crashlytics.sharedInstance().setUserIdentifier(userName)
        Crashlytics.sharedInstance().setUserName(userName)
    }
    
    // MARK: - Memory management
    override func didReceiveMemoryWarning() {
        let memoryinuse = report_memory()
        let message = "MemoryWarning. Memory in use: \(memoryinuse)"
        
        Crashlytics.sharedInstance().recordError(NSError(domain: "ViewController", code: 9999, userInfo: ["filename" : "AppDelegate", "functionName": "ViewController", "description": message]))
        print("[ViewController] MemoryWarning. Memory in use: \(memoryinuse)")
        super.didReceiveMemoryWarning()
    }
    
    func report_memory() -> String {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            print("Memory used in bytes: \(taskInfo.resident_size)")
        }
        else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
            return "error"
        }
        
        let mbinuse =
            taskInfo.resident_size / 1000000
        
        return String(mbinuse) + " MB"
    }
    
    // MARK: - UITextfield delegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func sendNotification(_ text: String) {
        // Configure the notification's payload.
        let content = UNMutableNotificationContent()
        content.title = "AutoMode"
        content.body = text
        content.sound = UNNotificationSound.default
        
        // Deliver the notification in x seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(10), repeats: false)
        let request = UNNotificationRequest(identifier: "AutoMode"+text, content: content, trigger: trigger) // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.add(request) { (error : Error?) in
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        
        Answers.logCustomEvent(withName: #function,
                               customAttributes: [
                                "detail" : "Notification received \(notification.request.content.categoryIdentifier) ",
                                "filename" : #file,
                                "systemVersion": UIDevice.current.systemVersion
            ])
//        if notification.request.content.categoryIdentifier ==
//            "SevenDay" {
            completionHandler(.sound)
//            return
//        }
//        else {
//            // Handle other notification types...
//        }
//
//        // Don't alert the user for other types.
//        completionHandler(UNNotificationPresentationOptions(rawValue: 0))
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:
        @escaping () -> Void) {
        Answers.logCustomEvent(withName: #function,
                               customAttributes: [
                                "detail" : "Notification received \(response.notification.request.content.categoryIdentifier)",
                                "filename" : #file,
                                "systemVersion": UIDevice.current.systemVersion
            ])

        completionHandler()
    }
}
