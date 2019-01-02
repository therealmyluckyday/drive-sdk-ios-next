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
    var rxTripId: PublishSubject<NSUUID> { get }
    func start()
    func stop()
}


public class TripRecorder: TripRecorderProtocol {
    // MARK: Property
    private let collector: FixCollector
    private var rxEventType = PublishSubject<EventType>()
    private var rxFix = PublishSubject<Fix>()
    private let rxDisposeBag = DisposeBag()
    private let apiTrip: APITrip
    internal let persistantQueue: PersistantQueue
    public let rxTripId = PublishSubject<NSUUID>()
    
    // MARK: TripRecorder Protocol    
    public func start() {
        collector.startCollect()
    }
    
    public func stop() {
        collector.stopCollect()
    }
    
    // MARK: Lifecycle
    public init(configuration: TripRecorderConfiguration, sessionManager: APISessionManagerProtocol) {
        persistantQueue = PersistantQueue(eventType: rxEventType, fixes: rxFix, scheduler: configuration.rxScheduler, rxTripId: rxTripId, tripInfos: configuration.tripInfos)
        apiTrip = APITrip(apiSessionManager: sessionManager)
        collector = FixCollector(eventsType: rxEventType, fixes: rxFix, scheduler: configuration.rxScheduler)
        
        configuration.tripRecorderFeatures.forEach { (feature) in
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
                let motionTracker = MotionTracker(sensor: motionManager, scheduler: configuration.rxScheduler)
                collector.collect(tracker: motionTracker)
                break
            }
        }
        self.subscribe(providerTrip: persistantQueue.providerTrip, scheduler: configuration.rxScheduler)
    }
    
    func subscribe(providerTrip: PublishSubject<TripChunk>, scheduler: ImmediateSchedulerType) {
        providerTrip.asObservable().observeOn(scheduler).subscribe { [weak self](event) in
            if let trip = event.element {
                self?.apiTrip.sendTrip(trip: trip)
            }
            }.disposed(by: rxDisposeBag)
    }
}
