//
//  Tracker.swift
//  TexDriveSDK
//
//  Created by Erwan MASSON on 02/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift

public enum Result<T>{
    case Success(T)
    case Failure(Error)
}


protocol Tracker: GenericTracker {
    associatedtype T: Fix
    func provideFix() -> (PublishSubject<Result<T>>)
}

protocol GenericTracker {
    func enableTracking()
    func disableTracking()
}
