//
//  LogRxTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 08/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift

@testable import TexDriveSDK

class LogRxTests: XCTestCase {
    private var disposeBag : DisposeBag?
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    // MARK: func print(_ description: String, type: LogType = .Info, fileName: String, functionName: String? = nil)
    func testPrint() {
        let type = LogType.Error
        let detail = "myDetail"
        let file = #file
        let function = #function
        let rx_log = PublishSubject<LogMessage>()
        let log = LogRx(rxLog: rx_log)
        var isCalled = false
        
        rx_log.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: disposeBag!)
        
        log.print(detail, type: type, fileName: file, functionName: function)
        
        XCTAssert(isCalled)
    }
    
    func testPrintWithoutFunction() {
        let type = LogType.Error
        let detail = "myDetail"
        let file = #file
        let rx_log = PublishSubject<LogMessage>()
        let log = LogRx(rxLog: rx_log)
        var isCalled = false
        
        rx_log.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, "testPrintWithoutFunction()")
            }
            }.disposed(by: disposeBag!)
        
        log.print(detail, type: type, fileName: file)
        
        XCTAssert(isCalled)
    }
    
    // MARK: func warning(_ description: String, fileName: String = #file, functionName: String = #function)
    func testWarning() {
        let type = LogType.Warning
        let detail = "myDetail"
        let file = #file
        let function = #function
        let rx_log = PublishSubject<LogMessage>()
        let log = LogRx(rxLog: rx_log)
        var isCalled = false
        
        rx_log.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: disposeBag!)
        
        log.warning(detail, fileName: file, functionName: function)
        
        XCTAssert(isCalled)
    }
    
    func testWarningShort() {
        let type = LogType.Warning
        let detail = "myDetail"
        let function = #function
        let rx_log = PublishSubject<LogMessage>()
        let log = LogRx(rxLog: rx_log)
        var isCalled = false
        
        rx_log.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: disposeBag!)
        
        log.warning(detail)
        
        XCTAssert(isCalled)
    }
    
    // MARK: func error(_ description: String, fileName: String = #file, functionName: String = #function)
    func testError() {
        let type = LogType.Error
        let detail = "myDetail"
        let file = #file
        let function = #function
        let rx_log = PublishSubject<LogMessage>()
        let log = LogRx(rxLog: rx_log)
        var isCalled = false
        
        rx_log.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: disposeBag!)
        
        log.error(detail, fileName: file, functionName: function)
        
        XCTAssert(isCalled)
    }
    
    func testErrorShort() {
        let type = LogType.Error
        let detail = "myDetail"
        let function = #function
        let rx_log = PublishSubject<LogMessage>()
        let log = LogRx(rxLog: rx_log)
        var isCalled = false
        
        rx_log.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: disposeBag!)
        
        log.error(detail)
        
        XCTAssert(isCalled)
    }
}
