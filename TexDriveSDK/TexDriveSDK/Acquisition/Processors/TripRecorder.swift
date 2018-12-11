//
//  TripRecorder.swift
//  TexDriveSDK
//
//  Created by Erwan MASSON on 04/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

public protocol TripRecorderProtocol {
    func start()
    func stop()
}


public class TripRecorder: TripRecorderProtocol {
    // MARK: Property
    private let collector: FixCollector
    internal let persistantQueue: PersistantQueue
    private var rx_eventType = PublishSubject<EventType>()
    private var rx_fix = PublishSubject<Fix>()
    private let apiTrip: APITrip
    
    // MARK: TripRecorder Protocol    
    public func start() {
        collector.startCollect()
    }
    
    public func stop() {
        collector.stopCollect()
    }
    
    // MARK: Lifecycle
    public init(config: ConfigurationProtocol, sessionManager: APISessionManagerProtocol) {
        persistantQueue = PersistantQueue(eventType: rx_eventType, fixes: rx_fix, scheduler: config.rx_scheduler)
        apiTrip = APITrip(apiSessionManager: config.generateAPISessionManager())
        apiTrip.subscribe(providerTrip: persistantQueue.providerTrip, scheduler: config.rx_scheduler)
        collector = FixCollector(eventsType: rx_eventType, fixes: rx_fix, scheduler: config.rx_scheduler)
        
        config.tripRecorderFeatures.forEach { (feature) in
            switch feature {
            case .Location(let locationManager):
                let locationTracker = LocationTracker(sensor: locationManager)
                collector.collect(tracker: locationTracker)
                break
            case .Battery:
                let batteryTracker = BatteryTracker(sensor: UIDevice.current)
                collector.collect(tracker: batteryTracker)
                break
            case .PhoneCall(let callObserver):
                let callTracker = CallTracker(sensor: callObserver)
                collector.collect(tracker: callTracker)
                break
            case .Motion(let motionManager):
                let motionTracker = MotionTracker(sensor: motionManager, scheduler: config.rx_scheduler)
                collector.collect(tracker: motionTracker)
                break
            }
        }
    }
}
