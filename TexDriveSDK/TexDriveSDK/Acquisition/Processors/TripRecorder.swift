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
    private var rxEventType = PublishSubject<EventType>()
    private var rxFix = PublishSubject<Fix>()
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
        persistantQueue = PersistantQueue(eventType: rxEventType, fixes: rxFix, scheduler: config.rxScheduler)
        apiTrip = APITrip(apiSessionManager: config.generateAPISessionManager())
        apiTrip.subscribe(providerTrip: persistantQueue.providerTrip, scheduler: config.rxScheduler)
        collector = FixCollector(eventsType: rxEventType, fixes: rxFix, scheduler: config.rxScheduler)
        
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
                let motionTracker = MotionTracker(sensor: motionManager, scheduler: config.rxScheduler)
                collector.collect(tracker: motionTracker)
                break
            }
        }
    }
}
