//
//  MotionTracker.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 16/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift
import CoreMotion

class MotionTracker: Tracker {
    // MARK: Property
    private var rxMotionProviderFix = PublishSubject<Result<MotionFix>>()
    private var motionSensor: CMMotionManager
    private var operationQueue = OperationQueue()
    private let accelerationThreshold = 2.5
    private let motionBuffer: MotionBuffer
    private var rxDisposeBag = DisposeBag()
    private let rxScheduler: SerialDispatchQueueScheduler
    
    // MARK: Lifecycle
    init(sensor: CMMotionManager, scheduler: SerialDispatchQueueScheduler, buffer: MotionBuffer = MotionBuffer()) {
        motionSensor = sensor
        motionSensor.deviceMotionUpdateInterval = 0.01;
        motionSensor.showsDeviceMovementDisplay = true
        motionBuffer = buffer
        operationQueue.maxConcurrentOperationCount = 1
        rxScheduler = scheduler
    }
    
    // MARK: Protocol Tracker
    typealias T = MotionFix

    func enableTracking() {
        motionBuffer.rxCrashMotionFix.asObservable().observeOn(rxScheduler).subscribe { [weak self](event) in
            if let motions = event.element {
                for motion in motions {
                    self?.provideFix().onNext(Result.Success(motion))
                }
            }
        }.disposed(by: rxDisposeBag)
        
        motionSensor.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical, to: operationQueue) { [weak self](motion, error) in
            guard let motion = motion, error == nil else {
                self?.provideFix().onNext(Result.Failure(error!))
                return
            }
            if let accelerationThreshold = self?.accelerationThreshold {
                let motionFix = MotionFix(timestamp: motion.timestamp, accelerationMotion: MotionFix.convert(acceleration: motion.userAcceleration), gravityMotion: MotionFix.convert(acceleration: motion.gravity), magnetometerMotion: MotionFix.convert(field: motion.magneticField.field), crashDetected: MotionFix.normL2Acceleration(motion: motion) > accelerationThreshold)
                self?.motionBuffer.append(fix: motionFix)
            }
        }
    }
    
    func disableTracking() {
        motionSensor.stopDeviceMotionUpdates()
    }
    
    func provideFix() -> PublishSubject<Result<MotionFix>> {
        return rxMotionProviderFix;
    }
}
