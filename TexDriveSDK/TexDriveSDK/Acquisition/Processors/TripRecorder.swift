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
import RxSwiftExt
import OSLog

public protocol TripRecorderProtocol {
    var currentTripId: TripId? { get }
    var tripIdFinished: PublishSubject<TripId> { get }
    func start()
    func stop()
}

public extension Notification.Name {
    static let AXAEventTripRecordStart
                = NSNotification.Name("AXAEventTripRecordStart")
    static let AXAEventTripRecordStop
                = NSNotification.Name("AXAEventTripRecordStop")
}

public class TripRecorder: TripRecorderProtocol {
    // MARK: - Property
    private let collector: FixCollector
    private var rxEventType = PublishSubject<EventType>()
    private let rxDisposeBag = DisposeBag()
    private let apiTrip: APITrip
    private var tripDistance: Double = 0
    private var rxFix = PublishSubject<Fix>()
    
    internal var autoMode: AutoMode?
    internal let persistantQueue: PersistantQueue
    internal let rxDispatchQueueScheduler: SerialDispatchQueueScheduler
    
    public let rxTripId = PublishSubject<TripId>()
    public var rxTripProgress = PublishSubject<TripProgress>()
    
    // MARK: SDKV2 Compatibility
    public var isRecording: Bool {
        get {
            return currentTripId != nil
        }
    }
    public var startTime: Date?
    
    // MARK: Public
    public var currentTripId: TripId?
    public let tripIdFinished: PublishSubject<TripId>
    
    public var rxIsDriving: PublishSubject<Bool>? {
        get {
            return self.autoMode?.rxIsDriving
        }
    }
    
    // MARK: - TripRecorder Protocol
    public func start() {
        collector.startCollect()
        startTime = Date()
        tripDistance = 0
        if let autoMode = self.autoMode, !autoMode.isServiceStarted {
            autoMode.rxIsDriving.onNext(true)
        }
        NotificationCenter.default.post(name: Notification.Name.AXAEventTripRecordStart, object: nil)
    }
    
    public func stop() {
        collector.stopCollect()
        currentTripId = nil
        startTime = nil
        if let autoMode = self.autoMode, !autoMode.isServiceStarted {
            autoMode.rxIsDriving.onNext(false)
        }
        NotificationCenter.default.post(name: Notification.Name.AXAEventTripRecordStop, object: nil)
    }
    
    public func activateAutoMode() {
        autoMode?.enable()
    }
    
    public func disableAutoMode() {
        autoMode?.disable()
    }
    
    // MARK: - Lifecycle
    public init(configuration: TripRecorderConfiguration, sessionManager: APITripSessionManagerProtocol) {
        rxDispatchQueueScheduler = configuration.rxScheduler
        apiTrip = APITrip(apiSessionManager: sessionManager)
        tripIdFinished = sessionManager.tripIdFinished
        persistantQueue = PersistantQueue(eventType: rxEventType, fixes: rxFix, scheduler: MainScheduler.asyncInstance, rxTripId: rxTripId, tripInfos: configuration.tripInfos, rxTripChunkSent: sessionManager.tripChunkSent)
        collector = FixCollector(eventsType: rxEventType, fixes: rxFix, scheduler: configuration.rxScheduler)
        configuration.tripRecorderFeatures.forEach { (feature) in
            switch feature {
            case .Location(let locationManager):
                let locationTracker = LocationTracker(sensor: locationManager.trackerLocationSensor)
                collector.collect(tracker: locationTracker)
                self.autoMode = AutoMode(locationManager: locationManager)
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

        self.rxTripId.asObservable().observeOn(MainScheduler.instance).subscribe {[weak self] (event) in
            if let tripId = event.element {
                self?.currentTripId = tripId
            }
            }.disposed(by: rxDisposeBag)
        self.configureTripProgress()
    }
    
    func subscribe(providerTrip: PublishSubject<TripChunk>, scheduler: ImmediateSchedulerType) {
        providerTrip.asObservable().observeOn(scheduler).subscribe { [weak self](event) in
            if let trip = event.element {
                self?.apiTrip.sendTrip(trip: trip)
            }
            }.disposed(by: rxDisposeBag)
    }
    
    public func configureAutoMode(_ scheduler: SerialDispatchQueueScheduler = MainScheduler.instance) {
        guard let autoMode = autoMode else {
            Log.print("configureAutoMode error no automode", type: .Error)
            return
        }
        autoMode.rxIsDriving.asObserver().observeOn(scheduler).subscribe { [weak self](event) in
            if let isDriving = event.element {
                if isDriving {
                    self?.start()
                } else {
                    self?.stop()
                }
            }
            }.disposed(by: rxDisposeBag)
    }
    
    // MARK: - Configure TripProgress
    func configureTripProgress() {
        self.rxFix.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self] (event) in
            if let location = event.element as? LocationFix,
               let startTime = self?.startTime,
               let tripId = self?.currentTripId,
               let oldDistance = self?.tripDistance {
                let speed = location.speed
                let duration = location.timestamp - startTime.timeIntervalSince1970
                let newDistance = oldDistance + location.distance
                let tripProgress = TripProgress(tripId: tripId, speed: speed, distance: newDistance, duration: duration)
                self?.tripDistance = newDistance
                self?.rxTripProgress.onNext(tripProgress)
            }
        }.disposed(by: rxDisposeBag)
    }

    // MARK: - SDK V2 compatibility
    public func startTrip() {
        guard !isRecording else {
            return
        }
        start()
    }
    
    public func stopTrip() {
        guard isRecording else {
            return
        }
        stop()
    }
}
