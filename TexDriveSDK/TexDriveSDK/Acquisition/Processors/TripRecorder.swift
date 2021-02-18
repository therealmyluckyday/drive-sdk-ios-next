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
    var currentTripId   : TripId? { get }
    var tripIdFinished  : PublishSubject<TripId> { get }
    func start(date: Date)
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
    // MARK: Private
    private let collector               : FixCollector
    private var rxEventType             = PublishSubject<EventType>()
    private let apiTrip                 : APITrip
    private var tripDistance: Double    = 0
    private var currentLocation: LocationFix?
    internal let rxDisposeBag           = DisposeBag()
    
    // MARK: Internal
    //@LateInitialized internal var autoMode               : AutoMode
    internal var autoMode               : AutoMode?
    internal let persistantQueue        : PersistantQueue
    internal var rxFix                  = PublishSubject<Fix>()
    internal let rxDispatchQueueScheduler: SerialDispatchQueueScheduler
    
    
    
    // MARK: Public
    public let rxTripId         = PublishSubject<TripId>()
    public var rxTripProgress   = PublishSubject<TripProgress>()
    public var currentTripId    : TripId?
    public let tripIdFinished   : PublishSubject<TripId>
    public var startTime        : Date?
    public var rxIsDriving      : PublishSubject<Bool> {
        get {
            return self.autoMode != nil ? self.autoMode!.rxIsDriving : PublishSubject<Bool>()
        }
    }
    public var isRecording      : Bool {
        get {
            return currentTripId != nil
        }
    }
    
    // MARK: - TripRecorder Protocol
    public func start(date: Date = Date()) {
        tripDistance    = 0
        startTime       = date
        collector.startCollect()
        if let serviceStarted = autoMode?.isServiceStarted,
           serviceStarted == false {
            autoMode?.rxIsDriving.onNext(true)
        }
        NotificationCenter.default.post(name: Notification.Name.AXAEventTripRecordStart, object: nil)
    }
    
    public func stop() {
        collector.stopCollect()
        startTime       = nil
        let resetTriprogress = (currentTripId != nil) ? TripProgress(tripId: currentTripId!, speed: 0, distance: 0, duration: 0) : nil
        currentTripId   = nil
        currentLocation = nil
        if let serviceStarted = autoMode?.isServiceStarted,
           serviceStarted == false {
            autoMode?.rxIsDriving.onNext(false)
        }
        NotificationCenter.default.post(name: Notification.Name.AXAEventTripRecordStop, object: nil)
        if let resetTriprogress = resetTriprogress {
            self.rxTripProgress.onNext(resetTriprogress)
        }
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
        self.subscribe(providerTrip: persistantQueue.providerTrip, providerOrderlyTrip: persistantQueue.providerOrderlyTrip, scheduler: configuration.rxScheduler)

        self.rxTripId.asObservable().observeOn(MainScheduler.instance).subscribe {[weak self] (event) in
            if let tripId = event.element {
                self?.currentTripId = tripId
            }
            }.disposed(by: rxDisposeBag)
        self.configureTripProgress()
    }
    
    // MARK: - Configure ApiTrip
    func subscribe(providerTrip: PublishSubject<TripChunk>, providerOrderlyTrip: PublishSubject<(String, String)>, scheduler: ImmediateSchedulerType) {
        providerOrderlyTrip.asObservable().observeOn(scheduler).subscribe { [weak self](event) in
            if let (payload, baseurl) = event.element {
                self?.apiTrip.sendTrip(body: payload, baseUrl: baseurl)
            }
            }.disposed(by: rxDisposeBag)
        
        providerTrip.asObservable().observeOn(scheduler).subscribe { [weak self](event) in
            if let trip = event.element {
                self?.apiTrip.sendTrip(trip: trip)
            }
            }.disposed(by: rxDisposeBag)
    }
    
    // MARK: - Configure Automode start & stop auto
    public func configureAutoMode(_ scheduler: SerialDispatchQueueScheduler = MainScheduler.instance) {
        autoMode?.rxIsDriving.asObserver().observeOn(scheduler).subscribe { [weak self](event) in
            if let isDriving = event.element {
                if isDriving {
                    self?.start()
                } else {
                    self?.stop()
                }
            }
         }.disposed(by: rxDisposeBag)
    }
    
    // MARK: - Configure TripProgress stream
    func configureTripProgress() {
        self.rxFix.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self] (event) in
            if let location     = event.element as? LocationFix,
               let startTime    = self?.startTime,
               let tripId       = self?.currentTripId,
               let oldDistance  = self?.tripDistance,
               location.distance > 0,
               location.speed   >= 0 {
                
                let speed       = location.speed
                let duration    = location.timestamp - startTime.timeIntervalSince1970
                let newDistance = oldDistance + location.distance
                if let oldLocation = self?.currentLocation {
                    let deltaTimestamp = (pow((location.timestamp - oldLocation.timestamp), 2)).squareRoot()
                    if (deltaTimestamp > Double(maxDelayBeetweenLocationTimeInSecond)) {
                        Log.print("[TripRecorder]tripProgress DO NOTHING : delta deltaTimestamp speed \(location.timestamp - oldLocation.timestamp) \(deltaTimestamp) \(location.speed)")
                        return
                    }
                }
                let tripProgress        = TripProgress(tripId: tripId, speed: speed, distance: newDistance, duration: duration)
                //	Log.print("[TripRecorder] tripProgress : %{public}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(tripProgress.distance) \(tripProgress.speed) \(location.speed)")
                self?.tripDistance      = newDistance
                self?.currentLocation   = location
                self?.update(tripProgress: tripProgress)
            }
        }.disposed(by: rxDisposeBag)
    }
    
    internal func update(tripProgress: TripProgress) {
        self.rxTripProgress.onNext(tripProgress)
    }
    
    
    // MARK: - Start & Stop trip
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
