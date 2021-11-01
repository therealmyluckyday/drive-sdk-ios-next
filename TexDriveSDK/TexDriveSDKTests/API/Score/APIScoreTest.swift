//
//  APIScoreTest.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 03/12/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift
@testable import TexDriveSDK

class APIScoreTest: XCTestCase {
    var rxDisposeBag: DisposeBag?
    var apiScore: APIScore?
    
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
        
        let urlScoreSessionConfiguration = URLSessionConfiguration.default
        urlScoreSessionConfiguration.timeoutIntervalForResource = 5
        let apiSessionManager = APIScoreSessionManager(configuration: TripInfos(appId: "youdrive_france_prospect", user: TexUser.Authentified("Erwan-ios12"), domain: Platform.Preproduction, isAPIV2: false), urlSessionConfiguration: urlScoreSessionConfiguration)
        apiScore = APIScore(apiSessionManager: apiSessionManager, locale: Locale.current)
    }
    
    override func tearDown() {
        rxDisposeBag = nil
        super.tearDown()
    }
    
    func testInit() {
        let urlScoreSessionConfiguration = URLSessionConfiguration.default
        urlScoreSessionConfiguration.timeoutIntervalForResource = 5
        let apiSessionManager = APIScoreSessionManager(configuration: TripInfos(appId: "youdrive_france_prospect", user: TexUser.Authentified("Erwan-ios12"), domain: Platform.Preproduction, isAPIV2: false), urlSessionConfiguration: urlScoreSessionConfiguration)
        apiScore = APIScore(apiSessionManager: apiSessionManager, locale: Locale.current)
    }

}


