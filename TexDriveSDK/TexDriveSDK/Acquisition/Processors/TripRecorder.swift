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
    var currentTripId: String { get }
    
    func start()
    func stop()
}


public class TripRecorder: TripRecorderProtocol {
    // MARK: Property
    private let collector: FixCollector
    private let persistantQueue: PersistantQueue
    private let configuration: Config
    private var rx_eventType = PublishSubject<EventType>()
    private var rx_fix = PublishSubject<Fix>()
    private let apiTrip: APITrip
    private let sessionManager: APISessionManager
    
    // MARK: TripRecorder Protocol
    public var currentTripId = NSUUID().uuidString
    
    public func start() {
        collector.startCollect()
    }
    
    public func stop() {
        collector.stopCollect()
    }
    
    // MARK: Lifecycle
    public init(config: Config) {
        persistantQueue = PersistantQueue(eventType: rx_eventType, fixes: rx_fix)
        sessionManager = APISessionManager(configuration: APIConfiguration(appId: config.appId, domain: Domain.Preproduction))
        apiTrip = APITrip(apiSessionManager: sessionManager)
        apiTrip.subscribe(providerTrip: persistantQueue.providerTrip)
        collector = FixCollector(eventsType: rx_eventType, fixes: rx_fix)
        configuration = config
        
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
                let motionTracker = MotionTracker(sensor: motionManager)
                collector.collect(tracker: motionTracker)
                break
            }
        }
    }
}

//@protocol AXATripRecorder <NSObject>
//
//@property(readonly) BOOL isRecording;
///** Called each time there is a new location during a trip record. */
//@property id<AXATripProgressDelegate> tripProgressDelegate;
///** Called when all data about a trip was sent to the server. It is safe to ask for a score. */
//@property id<AXATripUploadedDelegate> tripUploadedDelegate;
//@property(readonly) NSString * currentTripId;
//@property(readonly) int speed; /** Speed in km/h */
//@property(readonly) double distance; /** Distance in km */
//@property(readonly) int elapsedTime; /** Elapsed time since beginning in seconds */
//@property(readonly) NSDate * startTime;
//@property(readonly) CLLocation * startCoordinates;
//@property(readonly) CLLocation * lastCoordinates;
//
///**
// * Start collecting telematic data.
// *
// * @param mode Describe which reason is the cause of this start.
// */
//- (NSString *)startTripWithMode:(AXAToggleMode)mode;
//
///**
// * Stop collecting telematic data.
// *
// * @param mode Describe which reason is the cause of this start.
// */
//- (AXARecordedTrip*)stopTripWithMode:(AXAToggleMode)mode;
//
//@property (nonatomic) CGFloat stressedCaptureRate;
//@property (nonatomic) NSInteger motionBufferLimit;
//@property (nonatomic) NSInteger motionUpperBufferLimit;
//@property (nonatomic) CGFloat accelerationEventThreshold;
//@property (nonatomic) CGFloat rotationEventThreshold;
//@property (nonatomic) NSUInteger minDataPointSize;
//@property (nonatomic) NSUInteger maxDataPointSize;
//- (NSArray *)getSortedSpeedEventThresholds;
//
//@end
