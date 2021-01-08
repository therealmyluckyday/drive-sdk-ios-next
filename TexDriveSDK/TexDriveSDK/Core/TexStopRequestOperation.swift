//
//  TexStopRequestOperation.swift
//  TexDriveSDK
//
//  Created by A944VQ on 14/12/2020.
//  Copyright © 2020 Axa. All rights reserved.
//

import Foundation
import OSLog

let BGAppTaskRequestIdentifier = "com.texdrivesdk.processing.stop"
let BGTaskDictionaryBodyKey = "dictionaryBody"
let BGTaskBaseUrlKey = "baseUrl"

internal class TexStopRequestOperation: Operation {
    let sessionManager: APITripSessionManager
    init(_ apiTripSessionManager: APITripSessionManager) {
        sessionManager = apiTripSessionManager
    }
    
    override func main() {
        guard !isCancelled else {
            os_log("[BGTASK] My TexStopRequestOperation is CANCELED NOW! BGTASK" , log: OSLog.texDriveSDK, type: OSLogType.error)
            return
        }
        os_log("[BGTASK] My TexStopRequestOperation is executed NOW! BGTASK" , log: OSLog.texDriveSDK, type: OSLogType.info)
       let userDefaultsTexSDK = UserDefaults(suiteName: BGAppTaskRequestIdentifier)
        if let dictionaryBody = userDefaultsTexSDK?.value(forKey:BGTaskDictionaryBodyKey) as? [String : Any], let baseUrl = userDefaultsTexSDK?.value(forKey:BGTaskBaseUrlKey) as? String {
            self.sessionManager.put(dictionaryBody: dictionaryBody, baseUrl: baseUrl)
            sendNotification("BGTASK Sent")
        } else {
            os_log("[BGTASK] My TexStopRequestOperation retrieve data error" , log: OSLog.texDriveSDK, type: OSLogType.error)
        }
        os_log("[BGTASK] My TexStopRequestOperation is FINISHED NOW! BGTASK" , log: OSLog.texDriveSDK, type: OSLogType.info)
    }
    
    func sendNotification(_ text: String) {
        // Configure the notification's payload.
        let content = UNMutableNotificationContent()
        content.title = "AutoMode "
        content.body = text
        content.sound = UNNotificationSound.default
        
        // Deliver the notification in x seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(10), repeats: false)
        let request = UNNotificationRequest(identifier: "AutoMode"+text, content: content, trigger: trigger) // Schedule the notification.
        let center = UNUserNotificationCenter.current()

        center.add(request) { (error : Error?) in
        }
    }
 }
