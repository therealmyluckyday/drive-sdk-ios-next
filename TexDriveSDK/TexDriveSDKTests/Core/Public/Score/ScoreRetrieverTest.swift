//
//  ScoreRetrieverTest.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 10/12/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift

@testable import TexDriveSDK

class ScoreRetrieverTest: XCTestCase {
    var rxDisposeBag: DisposeBag?
    var scoreRetriever: ScoreRetriever?
    
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
        let user = TexUser.Authentified("Erwan-ios12")
        let appId = "youdrive_france_prospect"
        
        let urlScoreSessionConfiguration = URLSessionConfiguration.default
        urlScoreSessionConfiguration.timeoutIntervalForResource = 5
        let configuration = TexConfig(applicationId: appId, currentUser: user, isAPIV2: false)
        configuration.select(domain: Platform.Preproduction, isAPIV2: false)
        let scoreSessionManager = APIScoreSessionManager(configuration: configuration.tripInfos, urlSessionConfiguration: urlScoreSessionConfiguration)
        scoreRetriever = ScoreRetriever(sessionManager: scoreSessionManager, locale: Locale.current)

    }
}
