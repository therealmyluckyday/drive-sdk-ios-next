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

public typealias TripId = NSUUID

class TripChunk: Collection {
    // MARK: Property
    let tripId: TripId
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
        Log.print("appendEventType \(eventType)")
        self.event = Event(eventType: eventType, timestamp:Date().timeIntervalSince1970)
    }
    
    func canUpload() -> Bool {
        if let _ = fixes.last as? MotionFix {
            return false
        }
        if let event = self.event, event.eventType == EventType.stop {
            return true
        }
        return fixes.count > TripConstant.MinFixesToSend
    }
    
    // MARK: Lifecycle
    convenience init(tripInfos: TripInfos) {
        self.init(tripId: TripChunk.generateTripId(), tripInfos: tripInfos)
    }
    
    init(tripId: TripId, tripInfos: TripInfos) {
        self.tripId = tripId
        self.tripInfos = tripInfos
    }
    
    // Private Method
    static func generateTripId() -> TripId {
        return TripId()
    }
    
    // MARK: Serialize
    func serialize() -> [String: Any] {
        var fix : [[String: Any]] = self.fixes.map({$0.serialize()})
        if let event = self.event {
            fix.append(event.serialize())
            Log.print("Event : \(event.eventType.rawValue)")
        }
        Log.print("Fixes send : \(fix.count)")
        var dictionary = [String : Any]()
        dictionary["trip_id"] = self.tripId.uuidString
        dictionary["fixes"] = fix

        return tripInfos.serializeWithGeneralInformation(dictionary: dictionary)
    }
    
}



