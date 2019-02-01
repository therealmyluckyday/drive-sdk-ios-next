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

public protocol TripRecorderProtocol {
    var currentTripId: TripId? { get }
    var tripIdFinished: PublishSubject<TripId> { get }
    func start()
    func stop()
}


public class TripRecorder: TripRecorderProtocol {
    // MARK: - Property
    private let collector: FixCollector
    private var rxEventType = PublishSubject<EventType>()
    private var rxFix = PublishSubject<Fix>()
    private let rxDisposeBag = DisposeBag()
    private let autoMode = AutoMode()
    private let apiTrip: APITrip
    internal let persistantQueue: PersistantQueue
    internal let persistantApp = PersistantApp()
    internal let rxTripId = PublishSubject<TripId>()
    
    // MARK: Public
    public var currentTripId: TripId?
    public let tripIdFinished: PublishSubject<TripId>
    
    public var rxState: PublishSubject<AutoModeDetectionState> {
        get {
            return self.autoMode.rxState
        }
    }

    
    // MARK: - TripRecorder Protocol
    public func start() {
        persistantApp.enable()
        collector.startCollect()
    }
    
    public func stop() {
        collector.stopCollect()
        persistantApp.disable()
    }
    
    public func activateAutoMode() {
        autoMode.rxState.asObserver().observeOn(MainScheduler.asyncInstance).pairwise().subscribe {[weak self] event in
            
            if let (state1, state2) = event.element {
                var oldState = ""
                var newState = ""
                switch state1 {
                case is DetectionOfStartState:
                    oldState = "DetectionOfStartState"
                    break
                case is DrivingState:
                    oldState = "DrivingState"
                    break
                case is DetectionOfStopState:
                    oldState = "DetectionOfStopState"
                    break
                case is StandbyState:
                    oldState = "StandbyState"
                    break
                case is DisabledState:
                    oldState = "DisabledState"
                    break
                default:
                    oldState = "\(state1)"
                }
                switch state2 {
                case is DetectionOfStartState:
                    newState = "DetectionOfStartState"
                    break
                case is DrivingState:
                    newState = "DrivingState"
                    break
                case is DetectionOfStopState:
                    newState = "DetectionOfStopState"
                    break
                case is StandbyState:
                    newState = "StandbyState"
                    break
                case is DisabledState:
                    newState = "DisabledState"
                    break
                default:
                    newState = "\(state2)"
                }
                Log.print("State 1 : \(oldState) , State 2: \(newState)")
                if state1 is DetectionOfStartState, state2 is DrivingState {
                    Log.print("START DETECTED")
                    self?.collector.startCollect()
                }
                if state1 is DetectionOfStopState, state2 is StandbyState {
                    Log.print("STOP DETECTED )")
                    self?.collector.stopCollect()
                }
                if state2 is DisabledState {
                    Log.print("DISABLE DETECTED )")
                    self?.collector.stopCollect()
                }
            }
        }.disposed(by: rxDisposeBag)
        autoMode.enable()
    }
    
    // MARK: - Lifecycle
    public init(configuration: TripRecorderConfiguration, sessionManager: APITripSessionManagerProtocol) {
        apiTrip = APITrip(apiSessionManager: sessionManager)
        tripIdFinished = sessionManager.tripIdFinished
        persistantQueue = PersistantQueue(eventType: rxEventType, fixes: rxFix, scheduler: configuration.rxScheduler, rxTripId: rxTripId, tripInfos: configuration.tripInfos, rxTripChunkSent: sessionManager.tripChunkSent)
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

        self.rxTripId.asObservable().observeOn(MainScheduler.instance).subscribe {[weak self] (event) in
            if let tripId = event.element {
                self?.currentTripId = tripId
            }
            }.disposed(by: rxDisposeBag)
    }
    
    func subscribe(providerTrip: PublishSubject<TripChunk>, scheduler: ImmediateSchedulerType) {
        providerTrip.asObservable().observeOn(scheduler).subscribe { [weak self](event) in
            if let trip = event.element {
                self?.apiTrip.sendTrip(trip: trip)
            }
            }.disposed(by: rxDisposeBag)
    }
}
