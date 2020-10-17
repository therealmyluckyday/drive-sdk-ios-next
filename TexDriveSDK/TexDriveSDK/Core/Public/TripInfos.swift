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
    func serializeWithGeneralInformationAPIV2(dictionary: [String: Any]) -> [String: Any]
}

public struct TripInfos: Equatable {
    let appId: String
    let user: TexUser
    let domain: Platform
    let isAPIV2: Bool
}

extension TripInfos: SerializeAPIGeneralInformation {
    func serializeWithGeneralInformation(dictionary: [String : Any]) -> [String : Any] {
        return isAPIV2 ? serializeWithGeneralInformationAPIV2(dictionary: dictionary)  : serializeWithGeneralInformationAPIV1(dictionary: dictionary)
    }
    
    func serializeWithGeneralInformationAPIV1(dictionary: [String : Any]) -> [String : Any] {
        var newDictionary = dictionary
        let uuid = UIDevice.current.identifierForVendor?.uuidString
        let timeZone = DateFormatter.formattedTimeZone()
        let os = UIDevice.current.os()
        let model = UIDevice.current.hardwareString()
        let sdkVersion = "3.0.0"
        let firstVia = "TEX_iOS_SDK/\(os)/\(sdkVersion)"
        
        switch user {
        case .Authentified(let clientId):
            newDictionary["client_id"] = clientId
        default:
            break
        }
        
        newDictionary["via"] = [firstVia]
        newDictionary["uid"] = uuid
        newDictionary["app_name"] = appId
        newDictionary["timezone"] = timeZone
        newDictionary["version"] = sdkVersion
        newDictionary["model"] = model
        newDictionary["os"] = os
        return newDictionary
    }
    
    func serializeWithGeneralInformationAPIV2(dictionary: [String : Any]) -> [String : Any] {
        var newDictionary = dictionary
        let uuid = UIDevice.current.identifierForVendor?.uuidString
        let os = UIDevice.current.os()
        let model = UIDevice.current.hardwareString()
        let sdkVersion = "3.0.0"

        switch user {
        case .Authentified(let clientId):
            newDictionary["client_id"] = clientId
        default:
            break
        }
        
        newDictionary["device_info"] = "\(model)/\(os)/\(sdkVersion)"
        newDictionary["device_id"] = uuid
        newDictionary["program_id"] = appId
        newDictionary["os"] = os
        return newDictionary
    }
}
