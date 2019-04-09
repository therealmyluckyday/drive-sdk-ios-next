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
import UserNotifications

class ViewController: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate {
    @IBOutlet weak var TripSegmentedControl: UISegmentedControl!
    @IBOutlet weak var scoreButton: UIButton!
    @IBOutlet weak var logTextField: UITextView!
    @IBOutlet weak var textfield: UITextField!
    
    var tripRecorder : TripRecorder?

    let rxDisposeBag = DisposeBag()
    lazy var currentTripId = { () -> TripId in
        if let tripId = tripRecorder?.currentTripId {
            return tripId
        }
        return TripId(uuidString: "0FDA9008-F429-4F53-9D8E-F3964B2CAF62")!
    }()
    lazy var texServices: TexServices? = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.texServices
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreButton.alpha = 1
        TripSegmentedControl.selectedSegmentIndex = 1
        let userId = "Erwan-"+UIDevice.current.systemName + UIDevice.current.systemVersion
        textfield.text = userId
        
        logTextField.isEditable = false
        CLLocationManager().requestAlwaysAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let userId = "Erwan-"+UIDevice.current.systemName + UIDevice.current.systemVersion
        self.showOldLog()
        self.configureTexSDK(withUserId: userId)
    }
    
    func showOldLog(cleanOld : Bool = false) {
        let fileName = "Test"
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        do {
            let currentData = try Data(contentsOf: fileURL)
            let oldLog = String(data: currentData, encoding: String.Encoding.utf8)!
//            self.appendText(string: oldLog)
            print(oldLog)
        } catch {
            print("Error \(error)")
        }
        if cleanOld {
            do {
                var currentData = Data()
                currentData.append("\n".data(using: String.Encoding.utf8)!)
                try currentData.write(to: fileURL, options: Data.WritingOptions.atomic)
            } catch {
                print("Error \(error)")
            }
        }
    }
    
    func configureTexSDK(withUserId: String) {
        self.logUser(userName: withUserId)
        guard let services = texServices else { return }
        services.tripRecorder.tripIdFinished.asObserver().observeOn(MainScheduler.asyncInstance).subscribe { [weak self] (event) in
            if let tripId = event.element {
                self?.appendText(string: "\n Trip finished: \n \(tripId.uuidString)")
                self?.saveLog("\n Trip finished: \n \(tripId.uuidString)")
            }
            }.disposed(by: rxDisposeBag)
        tripRecorder = services.tripRecorder
        tripRecorder?.rxIsDriving.asObserver().observeOn(MainScheduler.asyncInstance).subscribe({ [weak self] (event) in
            if let isDriving = event.element {
                self?.appendText(string: "\n isDriving: \n \(isDriving)")
                self?.saveLog("\n isDriving: \n \(isDriving)")
                if isDriving {
                    self?.sendNotification("Start")
                    self?.TripSegmentedControl.selectedSegmentIndex = 0
                    
                } else {
                    self?.sendNotification("Stop")
                    self?.TripSegmentedControl.selectedSegmentIndex = 1
                }
                self?.scoreButton.alpha = CGFloat((!isDriving).hashValue)
                
            }
        }).disposed(by: rxDisposeBag)
        
        services.rxScore.asObserver().observeOn(MainScheduler.asyncInstance).retry().subscribe({ [weak self] (event) in
            if let score = event.element {
                self?.appendText(string: "NEW SCORE \(score)")
            }
        }).disposed(by: rxDisposeBag)
        self.configureLog(services.logManager.rxLog)
        
    }
    
    @IBAction func tripSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        textfield.resignFirstResponder()
        switch sender.selectedSegmentIndex {
        case 1:
//            tripRecorder?.stop()
            print(" ")
        default:
//            tripRecorder?.start()
            print(" ")
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
        guard let services = texServices else { return }
        UIView.animate(withDuration: 0.6, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.scoreButton.alpha = 0
        }) { (finished) in
            
        }
        
        let rxScore = services.rxScore
        services.scoreRetriever.getScore(tripId: currentTripId, rxScore: rxScore)
    }
    
    // MARK: - Log Management
    func configureLog(_ log: PublishSubject<LogMessage>) {
        guard let services = texServices else { return }
        log.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in
            if let logDetail = event.element {
                self?.report(logDetail: logDetail)
            }
            }.disposed(by: self.rxDisposeBag)
        
        do {
            let regex = try NSRegularExpression(pattern: ".*(TripChunk|Score|URLRequestExtension.swift|API).*", options: NSRegularExpression.Options.caseInsensitive)
//            let regex = try NSRegularExpression(pattern: ".*.*", options: NSRegularExpression.Options.caseInsensitive)
            services.logManager.log(regex: regex, logType: LogType.Info)
        } catch {
            let customLog = OSLog(subsystem: "fr.axa.tex", category: #file)
            os_log("[ViewController][configureLog] regex error %@", log: customLog, type: .error, error.localizedDescription)
        }
    }
    
    func report(logDetail: LogMessage) {
        let customLog = OSLog(subsystem: "fr.axa.tex", category: logDetail.fileName)
//        print(logDetail.description)
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
//        self.appendText(string: newLog)
        self.saveLog(newLog)
    }
    
    func appendText(string: String) {
        let oldLog = self.logTextField.text ?? ""
        let text = "\(oldLog)\n\(string)"
        self.logTextField.text = text
        
    }
    
    func saveLog(_ string: String) {
        let fileName = "Test"
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        do {
            var currentData = try Data(contentsOf: fileURL)
            currentData.append("\(string)\n".data(using: String.Encoding.utf8)!)
            try currentData.write(to: fileURL, options: Data.WritingOptions.atomic)
        } catch {
            print("Error \(error)")
            do {
                try string.data(using: String.Encoding.utf8)!.write(to: fileURL)
            } catch {
                print("Error \(error)")
            }
        }
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
