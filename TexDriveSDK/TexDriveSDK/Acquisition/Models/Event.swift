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

class Event: Fix {
    // MARK: - Property
    let eventType: EventType
    let timestamp: TimeInterval
    
    // MARK: - Lifecycle
    init(eventType: EventType, timestamp: TimeInterval) {
        self.eventType = eventType
        self.timestamp = timestamp
    }
    
    // MARK: - CustomStringConvertible
    var description: String {
        get {
            var description = "Events: \(self.timestamp) \n"
            
            for eventDescription in self.serializeEvents() {
                description += " "+eventDescription
            }
            return description
        }
    }
    
    // MARK: - Serialize
    func serialize() -> [String : Any] {
        let (key, value) = self.serializeTimestamp()
        let dictionary = ["event": self.serializeEvents(), key: value] as [String : Any]
        return dictionary
    }
    
    private func serializeEvents() -> [String] {
        // @EMA @TODO serialize in array when it is an autostop or autostart
//        return eventsType.map({ (eventType) -> String in
//            return eventType.rawValue
//        })
        return [eventType.rawValue]
    }
    
    func serializeAPIV2() -> [String : Any] {
        let (key, value) = self.serializeTimestamp()
        let dictionary = ["events": self.serializeEvents(), key: value] as [String : Any]
        return dictionary
    }
}
