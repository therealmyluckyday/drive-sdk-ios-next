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
        let rx_log = PublishSubject<LogMessage>()
        let log = LogRxDefault(rxLog: rx_log, currentFile: file)
        
        XCTAssertEqual(log.fileName, file)
    }
    
    // MARK: func print(_ description: String, type: LogType = .Info, fileName: String, functionName: String? = nil)
    func testPrint() {
        let type = LogType.Info
        let detail = "myDetail"
        let file = #file
        let function = #function
        let rx_log = PublishSubject<LogMessage>()
        let log = LogRxDefault(rxLog: rx_log, currentFile: file)
        var isCalled = false
        
        rx_log.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxDefaultTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: disposeBag!)
        
        log.print(detail, type: type, fileName: file, functionName: function)
        XCTAssert(isCalled)
    }
    
    func testPrintShort() {
        let type = LogType.Info
        let detail = "myDetail"
        let file = #file
        let function = #function
        let rx_log = PublishSubject<LogMessage>()
        let log = LogRxDefault(rxLog: rx_log, currentFile: file)
        var isCalled = false
        
        rx_log.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxDefaultTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: disposeBag!)
        
        log.print(detail)
        XCTAssert(isCalled)
    }
}
