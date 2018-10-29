//
//  Trip.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 23/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

struct TripConstant {
    static let MaxSizeFixes = 5
}

class Trip: Collection {
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
    subscript(index: Index) -> Iterator.Element {
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
        return fixes.count > TripConstant.MaxSizeFixes
    }
    
    // MARK: Lifecycle
    convenience init() {
        self.init(tripId: Trip.generateTripId())
    }
    
    init(tripId: String) {
        self.tripId = tripId.uppercased()
    }
    
    // Private Method
    static func generateTripId() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
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
