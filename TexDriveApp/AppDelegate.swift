//
//  AppDelegate.swift
//  TexDriveApp
//
//  Created by Axa on 11/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import UIKit
import TexDriveSDK
import UserNotifications
import CoreLocation
import Firebase
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppDelegateTex {
    var texServices: TexServices?
    var window: UIWindow?
    var backgroundCompletionHandler: (() -> ())?
    let userId = "Erwan-"+UIDevice.current.systemName + UIDevice.current.systemVersion
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound];
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: options) {
            (granted, error) in
        }
        locationManager.requestAlwaysAuthorization()

        //#if canImport(Swiftui)
        //configureWithSwuiftui(withUserId: userId)
        //#else
        self.configureTexSDK(userId: userId)
        //#endif
        texServices?.registerBGTaskScheduler()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                   if granted == true && error == nil {
                       print("Notifications permitted")
                   } else {
                       print("Notifications not permitted")
                   }
               }
        
        return true
    }
    
    @available(iOS 13, *)
    func configureWithSwuiftui(withUserId: String) {
        configureTexSDKSwuiftui(userId: withUserId)
        let swuiftUIVC = HomeViewControllerSUI(tripRecorder: self.texServices!.tripRecorder! as! TripRecorderiOS13SwiftUI, texServices: self.texServices as! TexServicesiOS13SwiftUI)
        let hostVC = UIHostingController(rootView: swuiftUIVC)
        window?.rootViewController = hostVC
    }
    
    @available(iOS 13, *)
    func configureTexSDKSwuiftui(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
        let user = TexUser.Authentified(userId)
        let appId = "APP-TEST" //"youdrive_france_prospect" "APP-TEST"
        //let fakeLocationManager = FakeLocationManager()
        let builder = TexConfigBuilder(appId: appId, texUser: user, isAPIV2: true)
        do {
            //try builder.enableTripRecorder(locationManager: fakeLocationManager)
            try builder.enableTripRecorder()
            builder.select(platform: Platform.Production, isAPIV2: false) //Platform.APIV2Testing
            let config = builder.build()
            let serviceios13 = TexServicesiOS13SwiftUI.service(configuration: config) as! TexServicesiOS13SwiftUI
            texServices = serviceios13
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01)  {
                serviceios13.tripRecorderiOS13.configureAutoMode()
                serviceios13.tripRecorderiOS13.activateAutoMode()
                DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                    //fakeLocationManager.loadTrip(intervalBetweenGPSPointInSecond: 0.15)
                }
            }
        } catch ConfigurationError.LocationNotDetermined(let description) {
            print(description)
        } catch {
            print("\(error)")
        }
    }
    
    func configureTexSDK(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
        let user = TexUser.Authentified(userId)
        let appId = "APP-TEST" //"youdrive_france_prospect" "APP-TEST"
        //let fakeLocationManager = FakeLocationManager()
        let builder = TexConfigBuilder(appId: appId, texUser: user, isAPIV2: false)
        do {
            //try builder.enableTripRecorder(locationManager: fakeLocationManager)
            try builder.enableTripRecorder()
            builder.select(platform: Platform.Production, isAPIV2: false) //Platform.APIV2Testing
            let config = builder.build()
            let service = TexServices.service(configuration: config)
            texServices = service
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                service.tripRecorder?.configureAutoMode()
                service.tripRecorder?.activateAutoMode()
                DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                   // fakeLocationManager.loadTrip(intervalBetweenGPSPointInSecond: 0.05)
                }
            }
        } catch ConfigurationError.LocationNotDetermined(let description) {
            print(description)
        } catch {
            print("\(error)")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let memoryinuse = report_memory()
        let message = "Memory Infos. Memory in use: \(memoryinuse)"
        Analytics.logEvent(#function, parameters: [
            "filename" : #file,
            "functionName": #function,
            "type": "Info",
            "detail": message
        ])
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let memoryinuse = report_memory()
        let message = "MemoryWarning. Memory in use: \(memoryinuse)"
        Crashlytics.crashlytics().record(error: NSError(domain: "AppDelegate", code: 9999, userInfo: ["filename" : "AppDelegate", "functionName": "applicationWillTerminate", "description": message]))

        Analytics.logEvent(#function, parameters: [
            "filename" : #file,
            "functionName": #function,
            "type": "Info",
            "detail": message
        ])
    }
    
    // MARK: Background mode for URLSession
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
    }
    
    // MARK: Memory management
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        let memoryinuse = report_memory()
        let message = "MemoryWarning. Memory in use: \(memoryinuse)"
        
        Crashlytics.crashlytics().record(error: NSError(domain: "AppDelegate", code: 6666, userInfo: ["filename" : "AppDelegate", "functionName": "applicationDidReceiveMemoryWarning", "description": message]))

        Analytics.logEvent( #function, parameters: [
        "filename" : #file,
        "functionName": #function,
        "type": "Info",
        "detail": message
        ])
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
        
        let mbinuse = taskInfo.resident_size / 1000000
        
        return String(mbinuse) + " MB"
    }
}


