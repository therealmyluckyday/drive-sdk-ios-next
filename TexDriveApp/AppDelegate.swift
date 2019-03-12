//
//  AppDelegate.swift
//  TexDriveApp
//
//  Created by Axa on 11/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import UIKit
import TexDriveSDK
import Fabric
import Crashlytics
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppDelegateTex {
    var texServices: TexServices?
    var window: UIWindow?
    var backgroundCompletionHandler: (() -> ())?
    let userId = "Erwan-"+UIDevice.current.systemName + UIDevice.current.systemVersion
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        let options: UNAuthorizationOptions = [.alert, .badge, .sound];
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: options) {
            (granted, error) in
        }
        locationManager.requestAlwaysAuthorization()
        self.configureTexSDK(withUserId: userId)
        return true
    }
    
    func configureTexSDK(withUserId: String) {
        let user = User.Authentified(withUserId)
        
        do {
            ///"APP-TEST"
            if let configuration = try Config(applicationId: "youdrive_france_prospect", applicationLocale: Locale.current, currentUser: user, domain: Domain.Preproduction) {
                let service = TexServices.service(reconfigureWith: configuration)
                texServices = service
                DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 2000)) {
                    service.tripRecorder.activateAutoMode()
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
        Answers.logCustomEvent(withName: #function,
                               customAttributes: [
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
        Crashlytics.sharedInstance().recordError(NSError(domain: "AppDelegate", code: 9999, userInfo: ["filename" : "AppDelegate", "functionName": "applicationWillTerminate", "description": message]))

        
        Answers.logCustomEvent(withName: #function,
                               customAttributes: [
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
        
        Crashlytics.sharedInstance().recordError(NSError(domain: "AppDelegate", code: 6666, userInfo: ["filename" : "AppDelegate", "functionName": "applicationDidReceiveMemoryWarning", "description": message]))

        
        Answers.logCustomEvent(withName: #function,
                               customAttributes: [
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


