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

class PersistantApp: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    let clLocationManager = CLLocationManager()
    let vlLocationManager = CLLocationManager()
    let locationManager: LocationManager
    let rxDisposeBag = DisposeBag()
    var lastLocationSaved: CLLocationCoordinate2D?
    let autoMode: AutoMode
    
    init(_ sharedAutoMode: AutoMode) {
        locationManager = sharedAutoMode.locationManager
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
        startReceivingVisitChanges()
    }
    
    public func enable() {
        clLocationManager.requestAlwaysAuthorization()
        clLocationManager.delegate = self
        clLocationManager.distanceFilter = kCLDistanceFilterNone
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        clLocationManager.activityType = .automotiveNavigation
        #if targetEnvironment(simulator)
        #else
        clLocationManager.allowsBackgroundLocationUpdates = true
        clLocationManager.pausesLocationUpdatesAutomatically = false
        #endif
    }
    
    public func disable() {
        clLocationManager.delegate = nil
    }
    
    public func startMonitorRegion() {
        sendNotification("startMonitorRegion")
        locationManager.rxLocation.takeLast(0).subscribe {[weak self](event) in
            if let location = event.element{
                self?.monitorRegionAtLocation(center: location.coordinate, identifier: "StopLocationPoint")
            }
            }.disposed(by: rxDisposeBag)
        
    }
    
    public func stopMonitorRegion() {
        sendNotification("stopMonitorRegion")
        locationManager.rxLocation.takeLast(0).subscribe {[weak self](event) in
            if let location = event.element{
                let maxDistance = CLLocationDistance(exactly: 100)!
                let region = CLCircularRegion(center: location.coordinate,
                                              radius: maxDistance, identifier: "StopLocationPoint")
                if let lastLocation = self?.lastLocationSaved, region.contains(lastLocation) {
                    return
                }
                self?.lastLocationSaved = location.coordinate
                region.notifyOnEntry = true
                region.notifyOnExit = true
                
                self?.clLocationManager.stopMonitoring(for: region)

            }
            }.disposed(by: rxDisposeBag)
        
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Log.print("didUpdateLocations")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.print("didFailWithError")
    }
    
    func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String ) {
        // Make sure the app is authorized.
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            // Make sure region monitoring is supported.
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                // Register the region.
                
//                let maxDistance = clLocationManager.maximumRegionMonitoringDistance
                let maxDistance = CLLocationDistance(exactly: 100)!
                let region = CLCircularRegion(center: center,
                                              radius: maxDistance, identifier: identifier)
                if let lastLocation = lastLocationSaved, region.contains(lastLocation) {
                    return
                }
                lastLocationSaved = center
                region.notifyOnEntry = true
                region.notifyOnExit = true
                
                clLocationManager.startMonitoring(for: region)
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
//            clLocationManager.stopMonitoring(for: region)
            sendNotification("Monitor Did Enter Region \(region)")
            Log.print("Monitor Did Enter Region")
            self.autoMode.detectionOfStart()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
//            clLocationManager.stopMonitoring(for: region)
            sendNotification("Monitor Did Exit Region")
            Log.print("Monitor Did Exit Region \(region)")
            self.autoMode.detectionOfStart()
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
    // MARK: - VisitLocation
    func startReceivingVisitChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            return
        }
        
        if !CLLocationManager.locationServicesEnabled() {
            // This service is not available.
            return
        }
        vlLocationManager.delegate = self
        vlLocationManager.startMonitoringVisits()
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // Do something with the visit.
        if -visit.departureDate.timeIntervalSinceNow < 180 {
            sendNotification("Visit Did Exit VisitLocation -visit.departureDate.timeIntervalSinceNow < 180")
        }
        
        if -visit.arrivalDate.timeIntervalSinceNow < 180 {
            sendNotification("Visit Did Exit VisitLocation -visit.arrivalDate.timeIntervalSinceNow < 180")
        }
    }
}
