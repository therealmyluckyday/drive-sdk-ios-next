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
