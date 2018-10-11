//
//  Tracker.swift
//  TexDriveSDK
//
//  Created by Erwan MASSON on 02/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift

enum Result<SpecificFix>{
    case Success(SpecificFix)
    case Failure(Error)
}


protocol Tracker {
    associatedtype T: Fix
    func enableTracking()
    func disableTracking()
    func provideFix() -> PublishSubject<Result<T>>
}

// MARK: Type Erasure
// https://medium.com/swiftworld/swift-world-type-erasure-5b720bc0318a
//class AnyTracker<T: Fix>: Tracker {
//    private let _closure: ((T) -> ())?
//    private let _enableTracking: () -> ()
//    private let _disableTracking: () -> ()
//    private let _provideFix: (_ fix: T) -> ()
//    var closure: ((T) -> ())? {
//        get {
//            return _closure
//        }
//        set {
//            
//        }
//    }
//    
//    func enableTracking() {
//        _enableTracking()
//    }
//    
//    func disableTracking() {
//        _disableTracking()
//    }
//    
//    func provideFix(fix: T) {
//        return _provideFix(fix)
//    }
//    
//    init<U: Tracker>(_ tracker: U) where U.T == T {
//        _closure = tracker.closure
//        _enableTracking = tracker.enableTracking
//        _disableTracking = tracker.disableTracking
//        _provideFix = tracker.provideFix
//    }
//}
