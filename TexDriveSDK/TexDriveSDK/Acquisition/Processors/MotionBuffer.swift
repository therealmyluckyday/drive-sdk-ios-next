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

/**

 func append(fix: MotionFix)
 
     +----+    crashMotionFix!=nil
     |fix +-------------+
     +----+             |
                        |
              +----FALSE+TRUE-->fix.timestamp > crashMotionfix.timestamp + 5 seconds
              |                               |
              +------------------------FALSE--+--TRUE+-------+
              v                                              v
             append(fix)<-------------------------------+dispatchCrashHandler
                 +
                 |
                 fix.isCrashDetected
                 |
          +--TRUE+FALSE---------------------------------------------+
          |                                                         |
          |                                                         |
          v                                                         |
crashMotionFix!=nil                                                 |
          |                                                         |
     FALSE+TRUE--------------+                                      |
      |                      |                                      |
      |                      v                                      |
      +-TRUE+fix.acceleration>crashMotionFix.acceleration+FALSE-----+
      |                                                             |
      v                                                             v
 crashMotionFix=fix+---------------------------------------->cleanBuffer
 
 */

class MotionBuffer {
    // MARK: Property
    private var motions = [MotionFix]()
    private var crashMotionFix: MotionFix?
    private var futureBufferSizeInSec: Double
    var rxCrashMotionFix = PublishSubject<[MotionFix]>()
    
    // MARK: Lifecycle
    init(futureBufferSizeInSecond: Int = MotionBufferConstant.defaultFutureBufferSizeInSec) {
        futureBufferSizeInSec = Double(futureBufferSizeInSecond)
    }
    
    // MARK: Public Method
    func append(fix: MotionFix) {
        // Check if the 5 second after crash is passed
        if let crashMotionFix = self.crashMotionFix, fix.timestamp >= crashMotionFix.timestamp + futureBufferSizeInSec {
            // Launch crash buffer
            Log.print("Dispatch Crash Motion crashMotionFix timestamp \(crashMotionFix.timestamp)")
            Log.print("Dispatch Crash Motion fix timestamp \(fix.timestamp)")
            dispatchCrashHandler(crashMotion: crashMotionFix)
        }
        
        motions.append(fix)
        if fix.isCrashDetected {
            // Crash timeline, we need to find the highest crash point between the old crash fix and the new one
            Log.print("new fix isCrashDetected \(fix.timestamp)")
            if let crashMotionFix = self.crashMotionFix {
                if fix.normL2Acceleration() > crashMotionFix.normL2Acceleration() {
                    self.crashMotionFix = fix
                }
            }
            else {
                self.crashMotionFix = fix
            }
            
            if let crashMotionFix = self.crashMotionFix {
                // Clean Before
                cleanBuffer(before: crashMotionFix.timestamp)
            }
        }
        else {
            if let crashMotionFix = self.crashMotionFix {
                // Clean buffer Xsec Before
                cleanBuffer(before: crashMotionFix.timestamp)
            }
            else {
                // Clean unused buffer
                cleanBuffer()
            }
        }
    }
    
    private func dispatchCrashHandler(crashMotion: MotionFix) {
        // Send crash info to FixCollector
        rxCrashMotionFix.onNext(motions)
        // Reset Crash Info
        crashMotionFix = nil
    }
    
    private func cleanBuffer() {
        if motions.count > MotionBufferConstant.bufferMaxLength() {
            let begin = motions.count - MotionBufferConstant.bufferMaxLength()
            motions = Array(motions[begin..<motions.count])
        }
    }
    
    private func cleanBuffer(before: TimeInterval) {
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
            if (motions.count - i) > MotionBufferConstant.bufferMaxLength() {
                i = motions.count - MotionBufferConstant.bufferMaxLength()
            }
            motions = Array(motions[i..<motions.count])
        }
    }
}
