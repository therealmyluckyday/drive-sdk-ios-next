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

class TripChunk: Collection {
    // MARK: Property
    let tripId: String //GUI generated. Format MUST be in capital
    private var fixes = [Fix]()
    var event: Event?
    let tripInfos: TripInfos
    
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
        self.event = Event(eventType: eventType, timestamp:Date().timeIntervalSince1970)
    }
    
    func canUpload() -> Bool {
        if let _ = fixes.last as? MotionFix, let eventCurrent = self.event, eventCurrent.eventType == EventType.crash {
            return false
        }
        return fixes.count > TripConstant.MinFixesToSend
    }
    
    // MARK: Lifecycle
    convenience init(tripInfos: TripInfos) {
        self.init(tripId: TripChunk.generateTripId(), tripInfos: tripInfos)
    }
    
    init(tripId: String, tripInfos: TripInfos) {
        self.tripId = tripId.uppercased()
        self.tripInfos = tripInfos
    }
    
    // Private Method
    // GUID voir uuid
    static func generateTripId() -> String {
        return UIDevice.current.identifierForVendor!.uuidString + "\(Date().timeIntervalSince1970)"
    }
    
    // MARK: Serialize
    func serialize() -> [String: Any] {
        var fix : [[String: Any]] = self.fixes.map({$0.serialize()})
        if let event = self.event {
            fix.append(event.serialize())
        }
        var dictionary = [String : Any]()
        dictionary["trip_id"] = self.tripId
        dictionary["fixes"] = fix

        return tripInfos.serializeWithGeneralInformation(dictionary: dictionary)
    }
    
}



