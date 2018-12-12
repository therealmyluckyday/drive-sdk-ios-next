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
    private var rxDisposeBag : DisposeBag?
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
    }
    
    override func tearDown() {
        rxDisposeBag = nil
        super.tearDown()
    }
    
    // MARK: func print(_ description: String, type: LogType = .Info, fileName: String, functionName: String? = nil)
    func testPrint() {
        let type = LogType.Error
        let detail = "myDetail"
        let file = #file
        let function = #function
        let rxLog = PublishSubject<LogMessage>()
        let log = LogRx(logMessage: rxLog)
        var isCalled = false
        
        rxLog.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: rxDisposeBag!)
        
        log.print(detail, type: type, fileName: file, functionName: function)
        
        XCTAssert(isCalled)
    }
    
    func testPrintWithoutFunction() {
        let type = LogType.Error
        let detail = "myDetail"
        let file = #file
        let rxLog = PublishSubject<LogMessage>()
        let log = LogRx(logMessage: rxLog)
        var isCalled = false
        
        rxLog.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, "testPrintWithoutFunction()")
            }
            }.disposed(by: rxDisposeBag!)
        
        log.print(detail, type: type, fileName: file)
        
        XCTAssert(isCalled)
    }
    
    // MARK: func warning(_ description: String, fileName: String = #file, functionName: String = #function)
    func testWarning() {
        let type = LogType.Warning
        let detail = "myDetail"
        let file = #file
        let function = #function
        let rxLog = PublishSubject<LogMessage>()
        let log = LogRx(logMessage: rxLog)
        var isCalled = false
        
        rxLog.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: rxDisposeBag!)
        
        log.warning(detail, fileName: file, functionName: function)
        
        XCTAssert(isCalled)
    }
    
    func testWarningShort() {
        let type = LogType.Warning
        let detail = "myDetail"
        let function = #function
        let rxLog = PublishSubject<LogMessage>()
        let log = LogRx(logMessage: rxLog)
        var isCalled = false
        
        rxLog.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: rxDisposeBag!)
        
        log.warning(detail)
        
        XCTAssert(isCalled)
    }
    
    // MARK: func error(_ description: String, fileName: String = #file, functionName: String = #function)
    func testError() {
        let type = LogType.Error
        let detail = "myDetail"
        let file = #file
        let function = #function
        let rxLog = PublishSubject<LogMessage>()
        let log = LogRx(logMessage: rxLog)
        var isCalled = false
        
        rxLog.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: rxDisposeBag!)
        
        log.error(detail, fileName: file, functionName: function)
        
        XCTAssert(isCalled)
    }
    
    func testErrorShort() {
        let type = LogType.Error
        let detail = "myDetail"
        let function = #function
        let rxLog = PublishSubject<LogMessage>()
        let log = LogRx(logMessage: rxLog)
        var isCalled = false
        
        rxLog.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: rxDisposeBag!)
        
        log.error(detail)
        
        XCTAssert(isCalled)
    }
}
