//
//  TexStopRequestOperation.swift
//  TexDriveSDK
//
//  Created by A944VQ on 14/12/2020.
//  Copyright © 2020 Axa. All rights reserved.
//

import Foundation
import OSLog
import KeychainAccess


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
        let keychain = Keychain(service: BGAppTaskRequestIdentifier)
        
        do {
            if let dataDictionaryBody = try? keychain.getData(BGTaskDictionaryBodyKey),
               let dictionaryBody =  try (JSONSerialization.jsonObject(with: dataDictionaryBody, options: JSONSerialization.ReadingOptions.allowFragments)) as? [String: Any],
               let baseUrl = try? keychain.getString(BGTaskBaseUrlKey) {
                self.sessionManager.put(dictionaryBody: dictionaryBody, baseUrl: baseUrl)
                
                sendNotification("BGTASK Sent")
                removeStopData()
                
                os_log("[BGTASK] My TexStopRequestOperation retrieve data test ok" , log: OSLog.texDriveSDK, type: OSLogType.info)
            } else {
                os_log("[BGTASK] My TexStopRequestOperation retrieve data error" , log: OSLog.texDriveSDK, type: OSLogType.error)
            }
            
        } catch {
            os_log("[BGTASK] My TexStopRequestOperation retrieve data error" , log: OSLog.texDriveSDK, type: OSLogType.error)   
        }
        
        os_log("[BGTASK] My TexStopRequestOperation is FINISHED NOW! BGTASK" , log: OSLog.texDriveSDK, type: OSLogType.info)    
    }
    
    func removeStopData() {
        do {
            let keychain = Keychain(service: BGAppTaskRequestIdentifier)
            try keychain.remove(BGTaskDictionaryBodyKey)
            try keychain.remove(BGTaskBaseUrlKey)
        } catch {
                os_log("[BGTASK] TexStopRequestOperation removeStopData error" , log: OSLog.texDriveSDK, type: OSLogType.error)
        }
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
