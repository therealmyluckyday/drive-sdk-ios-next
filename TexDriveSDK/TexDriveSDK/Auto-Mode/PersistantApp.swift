//
//  PersistantApp.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 21/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications
import RxSwift

class PersistantApp: NSObject, UNUserNotificationCenterDelegate {
    let rxDisposeBag = DisposeBag()
    var lastLocationSaved: CLLocationCoordinate2D?
    let autoMode: AutoMode
    
    init(_ sharedAutoMode: AutoMode) {
        autoMode = sharedAutoMode
        super.init()
        autoMode.rxIsDriving.asObserver().observeOn(MainScheduler.instance).subscribe { [weak self](event) in
            if let isDriving = event.element {
                if isDriving {
                    self?.stopMonitorRegion()
                } else {
                    self?.startMonitorRegion()
                }
            }
            }.disposed(by: rxDisposeBag)
        autoMode.locationManager.rxRegion.asObserver().observeOn(MainScheduler.instance).subscribe{ [weak self](event) in
            if let region = event.element {
                self?.sendNotification("Monitor Region \(region)")
                self?.autoMode.detectionOfStart()
            }
            }.disposed(by: rxDisposeBag)
    }
    
    public func enable() {
        autoMode.locationManager.locationManager.requestAlwaysAuthorization()
    }
    
    public func disable() {
        //        clLocationManager.delegate = nil
    }
    
    public func startMonitorRegion() {
        autoMode.locationManager.rxLocation.takeLast(0).subscribe {[weak self](event) in
            if let location = event.element{
                self?.sendNotification("startMonitorRegion")
                Log.print("startMonitorRegion")
                self?.monitorRegionAtLocation(center: location.coordinate, identifier: "StopLocationPoint")
            }
            }.disposed(by: rxDisposeBag)
        
    }
    
    public func stopMonitorRegion() {
        autoMode.locationManager.rxLocation.takeLast(0).subscribe {[weak self](event) in
            if let location = event.element{
                self?.sendNotification("stopMonitorRegion")
                let maxDistance = CLLocationDistance(exactly: 100)!
                let region = CLCircularRegion(center: location.coordinate,
                                              radius: maxDistance, identifier: "StopLocationPoint")
                if let lastLocation = self?.lastLocationSaved, region.contains(lastLocation) {
                    return
                }
                Log.print("stopMonitorRegion")
                self?.lastLocationSaved = location.coordinate
                region.notifyOnEntry = true
                region.notifyOnExit = true
                self?.autoMode.locationManager.locationManager.stopMonitoring(for: region)
            }
            }.disposed(by: rxDisposeBag)
        
    }
    
    
    
    func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String ) {
        // Make sure the app is authorized.
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            // Make sure region monitoring is supported.
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                // Register the region.
                let maxDistance = CLLocationDistance(exactly: 100)!
                let region = CLCircularRegion(center: center,
                                              radius: maxDistance, identifier: identifier)
                if let lastLocation = lastLocationSaved, region.contains(lastLocation) {
                    return
                }
                lastLocationSaved = center
                region.notifyOnEntry = true
                region.notifyOnExit = true
                
                autoMode.locationManager.locationManager.startMonitoring(for: region)
                
            }
        }
    }
    
    // MARK: - Notifications
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
        
        completionHandler(.sound)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:
        @escaping () -> Void) {
        
        completionHandler()
    }
}

