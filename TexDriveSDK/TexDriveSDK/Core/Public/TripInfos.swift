//
//  TripInfos.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 12/12/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
protocol SerializeAPIGeneralInformation {
    func serializeWithGeneralInformation(dictionary: [String: Any]) -> [String: Any]
}

public struct TripInfos: Equatable {
    let appId: String
    let user: TexUser
    let domain: Platform
}

extension TripInfos: SerializeAPIGeneralInformation {
    func serializeWithGeneralInformation(dictionary: [String : Any]) -> [String : Any] {
        var newDictionary = dictionary
        let uuid = UIDevice.current.identifierForVendor?.uuidString
        let timeZone = DateFormatter.formattedTimeZone()
        let os = UIDevice.current.os()
        let model = UIDevice.current.hardwareString()
        let sdkVersion = "3.0.0"
        let firstVia = "TEX_iOS_SDK/\(os)/\(sdkVersion)"
        //        token _texConfig.texUser.authToken

        switch user {
        case .Authentified(let clientId):
            newDictionary["client_id"] = clientId
        default:
            break
        }
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
