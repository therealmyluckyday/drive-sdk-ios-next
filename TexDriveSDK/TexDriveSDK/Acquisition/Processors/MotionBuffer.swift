//
//  MotionBuffer.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 16/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import CoreMotion
import RxSwift

struct MotionBufferConstant {
    static let defaultPastBufferSizeInSec = 10
    static let defaultFutureBufferSizeInSec = 5
    static let stressedCaptureRateInHertz = 100
    static func bufferMaxLength() -> Int {
        return stressedCaptureRateInHertz * (defaultPastBufferSizeInSec+defaultFutureBufferSizeInSec)
    }
}

class MotionBuffer {
    // MARK: Property
    private var motions = [MotionFix]()
    private var crashMotions = [MotionFix]()
    private var crashMotionFix: MotionFix?
    private var futureBufferSizeInSec: Double
    var rx_crashMotionFix = PublishSubject<[MotionFix]>()
    
    // MARK: Lifecycle
    init(futureBufferSizeInSecond: Int = MotionBufferConstant.defaultFutureBufferSizeInSec) {
        futureBufferSizeInSec = Double(futureBufferSizeInSecond)
    }
    
    // MARK: Public Method
    func append(fix: MotionFix) {
        let file = #file
        let function = #function
        // Check if the 5 second after crash is passed
        Log.print("fix motionTimestamp \(fix.timestamp)", type: .Info, file: file, function: function)
        Log.print("crashMotionFix.motionTimestamp \(String(describing: crashMotionFix?.timestamp))", type: .Info, file: file, function: function)
        Log.print("futureBufferSizeInSec: \(futureBufferSizeInSec)", type: .Info, file: file, function: function)
        if let crashMotionFix = self.crashMotionFix, fix.timestamp >= crashMotionFix.timestamp + futureBufferSizeInSec {
            // Launch crash buffer
            Log.print("DISSSSPATCH", type: .Info, file: file, function: function)
            dispatchCrashHandler(crashMotion: crashMotionFix)
        }
        
        motions.append(fix)
        if fix.isCrashDetected {
            // Only add Fix from different timestamp
            if let lastFix = crashMotions.last, fix.timestamp == lastFix.timestamp {
                return
            }
            Log.print("fix isCrashDetected", type: .Info, file: file, function: function)
            crashMotions.append(fix)
        }
        else {
            // Crash timeline finished we need to find the highest crash point
            if crashMotions.count > 0 {
                Log.print("crashMotions.count > 0 && !fix.isCrashDetected Find Highest peak", type: .Info, file: file, function: function)
                let highestPeakAcceleration = findHighestPeakAcceleration(motions: crashMotions)
                
                // Compare with current Crash
                if let fix = crashMotionFix, fix.normL2Acceleration() > highestPeakAcceleration.normL2Acceleration() || fix.timestamp == highestPeakAcceleration.timestamp {
                    // Do Nothing
                    Log.print("Do Nothing", type: .Info, file: file, function: function)
                    return
                }
                else {
                    // By changing crashMotionFix it will cancel last previous crash timer
                    Log.print("new CrashMotionFix", type: .Info, file: file, function: function)
                    crashMotionFix = highestPeakAcceleration
                    
                    // Clean Before
                    Log.print("cleanBuffer", type: .Info, file: file, function: function)
                    cleanBuffer(before: highestPeakAcceleration.timestamp)
                }
            }
            else {
                Log.print("clena unused buffer", type: .Info, file: file, function: function)
                // Clean unused buffer
                cleanBuffer()
            }
        }
        Log.print("MOTIONS: \(motions)", type: .Info, file: file, function: function)
        Log.print("crashMotions: \(crashMotions)", type: .Info, file: file, function: function)
        if let fix = crashMotionFix {
            Log.print("crashMotionFix: \(fix)", type: .Info, file: file, function: function)
        }
    }
    
    private func dispatchCrashHandler(crashMotion: MotionFix) {
        Log.print("dispatchCrashHandler", type: .Info, file: #file, function: #function)
        // Send crash info to FixCollector
        rx_crashMotionFix.onNext(motions)
        // Reset Crash Info
        crashMotionFix = nil
        // Only remove past
        crashMotions = [MotionFix]()
        Log.print("dispatchCrashHandler END", type: .Info, file: #file, function: #function)
    }
    
    private func findHighestPeakAcceleration(motions: [MotionFix]) -> MotionFix {
        Log.print("findHighestPeakAcceleration", type: .Info, file: #file, function: #function)
        var highestPeakAcceleration = motions.first!
        for fix in crashMotions {
            if fix.normL2Acceleration() > highestPeakAcceleration.normL2Acceleration() {
                highestPeakAcceleration = fix
            }
        }
        Log.print("findHighestPeakAcceleration END", type: .Info, file: #file, function: #function)
        return highestPeakAcceleration
    }
    
    private func cleanBuffer() {
        Log.print("cleanBufferW", type: .Info, file: #file, function: #function)
        if motions.count > MotionBufferConstant.bufferMaxLength() {
            let begin = motions.count - MotionBufferConstant.bufferMaxLength()
            motions = Array(motions[begin..<motions.count])
        }
        Log.print("cleanBuffer END", type: .Info, file: #file, function: #function)
    }
    
    private func cleanBuffer(before: TimeInterval) {
        Log.print("cleanBuffer BEFORE", type: .Info, file: #file, function: #function)
        if let crashMotionFix = crashMotionFix {
            var i = 0
            while i < motions.count {
                if motions[i].timestamp < crashMotionFix.timestamp - Double(MotionBufferConstant.defaultPastBufferSizeInSec) {
                    i += 1
                }
                else {
                    break
                }
            }
            print("i: \(i)")
            motions = Array(motions[i..<motions.count])
        }
        Log.print("cleanBuffer BEFORE", type: .Info, file: #file, function: #function)
    }
}
