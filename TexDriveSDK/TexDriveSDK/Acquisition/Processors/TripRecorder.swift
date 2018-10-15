//
//  TripRecorder.swift
//  TexDriveSDK
//
//  Created by Erwan MASSON on 04/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import CoreLocation

public protocol TripRecorderProtocol {
    var currentTripId: String { get }
    
    func start()
    func stop()
}


public class TripRecorder: TripRecorderProtocol {
    // MARK: Property
    private let collector: FixCollector
    
    // MARK: TripRecorder Protocol
    public var currentTripId = NSUUID().uuidString
    
    public func start() {
        collector.collect()
    }
    
    public func stop() {
        collector.stopCollect()
    }
    
    // MARK: Lifecycle
    public init(configuration: Config) {
        var locationTracker: LocationTracker?
        var batteryTracker: BatteryTracker?
        var callTracker : CallTracker?
        
        configuration.tripRecorderFeatures.forEach { (feature) in
            switch feature {
            case .Location(let locationManager):
                locationTracker = LocationTracker(locationSensor: locationManager)
                break
            case .Battery:
                batteryTracker = BatteryTracker(currentDevice: UIDevice.current)
                break
            case .PhoneCall(let callObserver):
                callTracker = CallTracker(callSensor: callObserver)
                break
            }
        }
        
        collector = FixCollector(newLocationTracker: locationTracker, newBatteryTracker: batteryTracker, newCallTracker: callTracker)
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
