//
//  DictionaryExtension.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 30/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

protocol SerializeAPIGeneralInformation {
    func serializeWithGeneralInformation(dictionary: [String: Any], appId: String) -> [String: Any]
}

extension Dictionary where Key == String {
    static func serializeWithGeneralInformation(dictionary: [String: Any], appId: String) -> [String: Any] {
        var newDictionary = dictionary
        let uuid = UIDevice.current.identifierForVendor?.uuidString
        let timeZone = DateFormatter.formattedTimeZone()
        let os = UIDevice.current.os()
        let model = UIDevice.current.hardwareString()
        let sdkVersion = Bundle(for: APITrip.self).infoDictionary!["CFBundleShortVersionString"] as! String
        let firstVia = "TEX_iOS_SDK/\(os)/\(sdkVersion)"
        //        token _texConfig.texUser.authToken
        //        client_id _texConfig.texUser.userId
        newDictionary["uid"] = uuid
        newDictionary["timezone"] = timeZone
        newDictionary["os"] = os
        newDictionary["model"] = model
        newDictionary["version"] = sdkVersion
        newDictionary["app_name"] = appId
        newDictionary["via"] = [firstVia]
        return newDictionary
    }
}
