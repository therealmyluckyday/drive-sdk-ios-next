//
//  StubAutoModeContextProtocol.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 19/02/2019.
//  Copyright © 2019 Axa. All rights reserved.
//


@testable import TexDriveSDK
@testable import RxSwift

class StubAutoModeContextProtocol: AutoModeContextProtocol {
    var rxState = PublishSubject<AutoModeDetectionState>()
    
    var state: AutoModeDetectionState?
}
