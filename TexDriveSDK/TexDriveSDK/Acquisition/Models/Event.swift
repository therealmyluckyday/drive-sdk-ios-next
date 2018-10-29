//
//  Event.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 22/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

enum EventType: String {
    case start = "start"
    case stop = "stop"
    case callIdle = "call_idle"
    case callRinging = "call_ringing"
    case callBusy = "call_busy"
    case crash = "crash"
}

class Event: Fix, Collection {
    
    // MARK: Property
    var eventsType = [EventType]()
    var timestamp: TimeInterval {
        get {
            return Date().timeIntervalSince1970
        }
    }
    // MARK: Protocol CustomStringConvertible
    var description: String {
        get {
            var description = "Events: \(self.timestamp) \n"
            if let firstEvent = eventsType.first {
                description += eventsType.reduce(firstEvent.rawValue) { $0 + ", " + $1.rawValue }
            }
            return description
        }
    }
    
    // MARK: Typealias & Property Collection Protocol
    typealias Element = EventType
    typealias Index = Int
    
    // The upper and lower bounds of the collection, used in iterations
    var startIndex: Index { return eventsType.startIndex }
    var endIndex: Index { return eventsType.endIndex }
    
    // Required subscript, based on a Array index
    subscript(index: Index) -> EventType {
        get { return eventsType[index] }
    }
    
    // Method that returns the next index when iterating
    func index(after i: Index) -> Index {
        return eventsType.index(after: i)
    }
    
    // MARK: Public function
    func append(eventType: EventType) {
        self.eventsType.append(eventType)
    }

    // MARK: Serialize
    func serialize() -> [String : Any] {
        let (key, value) = self.serializeTimestamp()
        let dictionary = ["event": self.serializeEvents(), key: value] as [String : Any]
        return dictionary
    }
    
    private func serializeEvents() -> [String] {
        return eventsType.map({ (eventType) -> String in
            return eventType.rawValue
        })
    }
}
