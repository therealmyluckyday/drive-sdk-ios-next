//
//  CallTracker.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 12/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import CallKit
import RxSwift

@available(iOS 10.0, *)
class CallTracker: NSObject, Tracker, CXCallObserverDelegate {
    // MARK: Property
    private var rxCallProviderFix = PublishSubject<Result<CallFix>>()
    private let callObserver: CXCallObserver
    private var lastState: CallFixState
    
    // MARK: Lifecycle Method
    init(sensor : CXCallObserver) {
        callObserver = sensor
        lastState = CallFixState.idle
    }
    
    // MARK: Tracker Protocol
    typealias T = CallFix
    func enableTracking() {
        callObserver.setDelegate(self, queue: nil)
    }
    
    func disableTracking() {
        callObserver.setDelegate(nil, queue: nil)
    }
    
    func provideFix() -> PublishSubject<Result<CallFix>> {
        return rxCallProviderFix
    }
    
    // MARK: CXCallObserverDelegate
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        let callFix = self.generate(call: call)
        self.newCallfFix(callFix: callFix)
    }
    
    func newCallfFix(callFix: CallFix) {
        Log.print("CALL \(callFix.state) \(lastState)")
        if lastState != callFix.state {
            rxCallProviderFix.asObserver().onNext(Result.Success(callFix))
            lastState = callFix.state
        }
    }

    // MARK Internal Method to check call
    // @vhiribarren You prefer convert in Tracker or in Fix ?
    func generate(call : CXCall) -> CallFix {
        var state = CallFixState.idle
        if call.isOnHold {
            state = CallFixState.ringing
        }
        else if call.hasConnected || call.isOutgoing {
            state = CallFixState.busy
        }
        
        return CallFix(timestamp: Date().timeIntervalSince1970, state: state)
    }
}
