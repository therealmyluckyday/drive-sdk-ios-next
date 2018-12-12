//
//  Trip.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 23/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

struct TripConstant {
    static let MinFixesToSend = 100
}

protocol SerializeAPIGeneralInformation {
    static func serializeWithGeneralInformation(dictionary: [String: Any], appId: String, user: User) -> [String: Any]
}

class TripChunk: Collection {
    // MARK: Property
    let tripId: String //GUI generated. Format MUST be in capital
    private var fixes = [Fix]()
    var event = Event()
    
    // MARK: Typealias & Property Collection Protocol
    typealias Element = Fix
    typealias Index = Int
    
    // The upper and lower bounds of the collection, used in iterations
    var startIndex: Index { return fixes.startIndex }
    var endIndex: Index { return fixes.endIndex }
    
    // Required subscript, based on a Array index
    subscript(index: Index) -> Fix {
        get { return fixes[index] }
    }
    
    // Method that returns the next index when iterating
    func index(after i: Index) -> Index {
        return fixes.index(after: i)
    }
    
    // MARK: Public function
    func append(fix: Fix) {
        self.fixes.append(fix)
    }
    
    func append(eventType: EventType) {
        self.event.append(eventType: eventType)
    }
    
    func canUpload() -> Bool {
        if event.count > 0 && event.contains(EventType.crash), let _ = fixes.last as? MotionFix {
            return false
        }
        return fixes.count > TripConstant.MinFixesToSend
    }
    
    // MARK: Lifecycle
    convenience init() {
        self.init(tripId: TripChunk.generateTripId())
    }
    
    init(tripId: String) {
        self.tripId = tripId.uppercased()
    }
    
    // Private Method
    //GUID voir uuid
    static func generateTripId() -> String {
        return UIDevice.current.identifierForVendor!.uuidString + "\(Date().timeIntervalSince1970)"
    }
    
    // MARK: Serialize
    func serialize() -> [String: Any] {
        var fix : [[String: Any]] = self.fixes.map({$0.serialize()})
        fix.append(self.event.serialize())
        var dictionary = [String : Any]()
        dictionary["trip_id"] = self.tripId
        dictionary["fixes"] = fix
        
        return dictionary
    }
}


extension TripChunk: SerializeAPIGeneralInformation {
    static func serializeWithGeneralInformation(dictionary: [String : Any], appId: String, user: User) -> [String : Any] {
        var newDictionary = dictionary
        let uuid = UIDevice.current.identifierForVendor?.uuidString
        let timeZone = DateFormatter.formattedTimeZone()
        let os = UIDevice.current.os()
        let model = UIDevice.current.hardwareString()
        let sdkVersion = Bundle(for: APITrip.self).infoDictionary!["CFBundleShortVersionString"] as! String
        let firstVia = "TEX_iOS_SDK/\(os)/\(sdkVersion)"
        //        token _texConfig.texUser.authToken
        //        client_id _texConfig.texUser.userId
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
