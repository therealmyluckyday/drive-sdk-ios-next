//
//  LogRxDefaultTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 08/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift

@testable import TexDriveSDK

class LogRxDefaultTests: XCTestCase {
    private var disposeBag : DisposeBag?
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    // MARK: init(rxLog: PublishSubject<LogDetail>, currentFile: String)
    func testInit() {
        let file = #file
        let rx_log = PublishSubject<LogDetail>()
        let log = LogRxDefault(rxLog: rx_log, currentFile: file)
        
        XCTAssertEqual(log.file, file)
    }
    
    // MARK: func print(_ description: String, type: LogType = .Info, file: String, function: String? = nil)
    func testPrint() {
        let type = LogType.Error
        let detail = "myDetail"
        let file = #file
        let function = #function
        let rx_log = PublishSubject<LogDetail>()
        let log = LogRxDefault(rxLog: rx_log, currentFile: file)
        var isCalled = false
        
        rx_log.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.detail, detail)
                XCTAssertEqual(logDetail.file, "LogRxDefaultTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.function!, function)
            }
            }.disposed(by: disposeBag!)
        
        log.print(detail, type: type, file: file, function: function)
        
        XCTAssert(isCalled)
    }
}
