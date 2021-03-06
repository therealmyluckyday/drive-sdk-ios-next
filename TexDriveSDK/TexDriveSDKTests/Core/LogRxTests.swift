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
        let regexPattern = ".*"
        let log = LogRx()
        let isCalledExpectation = XCTestExpectation(description: #function)
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Error, isTesting: true)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
                isCalledExpectation.fulfill()
            }
            }.disposed(by: rxDisposeBag!)
        
        log.print(detail, type: type, fileName: file, functionName: function)
        
        
        wait(for: [isCalledExpectation], timeout: 2)
    }
    
    func testPrintWithoutFunction() {
        let type = LogType.Error
        let detail = "myDetail"
        let file = #file
        let regexPattern = ".*"
        let log = LogRx()
        let isCalledExpectation = XCTestExpectation(description: #function)
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Error, isTesting: true)
        } catch {
            XCTAssertFalse(true)
        }
        log.rxLogOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, "testPrintWithoutFunction()")
                isCalledExpectation.fulfill()
            }
            }.disposed(by: rxDisposeBag!)
        
        log.print(detail, type: type, fileName: file)
        
        wait(for: [isCalledExpectation], timeout: 2)
    }
    
    // MARK: func warning(_ description: String, fileName: String = #file, functionName: String = #function)
    func testWarning() {
        let type = LogType.Warning
        let detail = "myDetail"
        let file = #file
        let function = #function
        let regexPattern = ".*"
        let log = LogRx()
        let isCalledExpectation = XCTestExpectation(description: #function)
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Warning, isTesting: true)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
                isCalledExpectation.fulfill()
            }
            }.disposed(by: rxDisposeBag!)
        
        log.warning(detail, fileName: file, functionName: function)
        
        wait(for: [isCalledExpectation], timeout: 2)
    }
    
    func testWarningShort() {
        let type = LogType.Warning
        let detail = "myDetail"
        let function = #function
        let regexPattern = ".*"
        let log = LogRx()
        let isCalledExpectation = XCTestExpectation(description: #function)
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Warning, isTesting: true)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
                isCalledExpectation.fulfill()
            }
            }.disposed(by: rxDisposeBag!)
        
        log.warning(detail)
        
        wait(for: [isCalledExpectation], timeout: 2)
    }
    
    // MARK: func error(_ description: String, fileName: String = #file, functionName: String = #function)
    func testError() {
        let type = LogType.Error
        let detail = "myDetail"
        let file = #file
        let function = #function
        let regexPattern = ".*"
        let log = LogRx()
        let isCalledExpectation = XCTestExpectation(description: #function)
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Error, isTesting: true)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
                isCalledExpectation.fulfill()
            }
            }.disposed(by: rxDisposeBag!)
        
        log.error(detail, fileName: file, functionName: function)
        
        wait(for: [isCalledExpectation], timeout: 2)
    }
    
    func testErrorShort() {
        let type = LogType.Error
        let detail = "myDetail"
        let function = #function
        let regexPattern = ".*"
        let log = LogRx()
        let isCalledExpectation = XCTestExpectation(description: #function)
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Error, isTesting: true)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, "LogRxTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
                isCalledExpectation.fulfill()
            }
            }.disposed(by: rxDisposeBag!)
        
        log.error(detail)
        
        wait(for: [isCalledExpectation], timeout: 2)
    }
    
    // MARK: lazy var mainLogger: LogImplementation
    func testConfigureAndMainLoggerCanLog() {
        let regexPattern = ".*"
        let log = LogRx()
        let isCalledExpectation = XCTestExpectation(description: #function)
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Info, isTesting: true)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            isCalledExpectation.fulfill()
            }.disposed(by: rxDisposeBag!)
        log.print("toto", type: LogType.Info, fileName: "superFile", functionName: "totoFunction")
        
        wait(for: [isCalledExpectation], timeout: 2)
    }
    
    func testConfigureAndMainLoggerCannotLog() {
        let regexPattern = "FALSE"
        let log = LogRx()
        let isCalledExpectation = XCTestExpectation(description: #function)
        isCalledExpectation.isInverted = true
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Info, isTesting: true)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            isCalledExpectation.fulfill()
            }.disposed(by: rxDisposeBag!)
        log.print("toto", type: LogType.Info, fileName: "superFile", functionName: "totoFunction")
        
        wait(for: [isCalledExpectation], timeout: 2)
    }
    
    // MARK: func getLogger(file: String) -> LogDefaultImplementation
    func testConfigureAndGetLoggerCanLog() {
        let regexPattern = ".*"
        let log = LogRx()
        let isCalledExpectation = XCTestExpectation(description: #function)
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Info, isTesting: true)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            isCalledExpectation.fulfill()
            }.disposed(by: rxDisposeBag!)
        log.print("", type: LogType.Info, functionName: "toto")
        
        wait(for: [isCalledExpectation], timeout: 2)
    }
    
    func testConfigureAndGetLoggerCannotLog() {
        let regexPattern = "FALSE"
        let log = LogRx()
        let isCalledExpectation = XCTestExpectation(description: #function)
        isCalledExpectation.isInverted = true
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Info, isTesting: true)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            isCalledExpectation.fulfill()
            }.disposed(by: rxDisposeBag!)
        log.print("", type: LogType.Info, functionName: "toto")
        
        wait(for: [isCalledExpectation], timeout: 2)
    }
    
    // MARK: func configure(regex: NSRegularExpression, logType: LogType)
    func testConfigure() {
        let regexPattern = ".*"
        let log = LogRx()
        let isCalledExpectation = XCTestExpectation(description: #function)
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Info, isTesting: true)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            isCalledExpectation.fulfill()
            }.disposed(by: rxDisposeBag!)
        log.print("", type: LogType.Info, functionName: "toto")
        log.print("toto", type: LogType.Info, fileName: "superFile", functionName: "totoFunction")
        
        wait(for: [isCalledExpectation], timeout: 2)
    }
    
    // MARK: func report(logDetail: LogDetail)
    func testReport() {
        let type = LogType.Info
        let detail = "sdodsfo"
        let file = "sdcidsfile"
        let log = LogRx()
        let function = #function
        let isCalledExpectation = XCTestExpectation(description: #function)
        
        let logDetail = LogMessage(type: type, detail: detail, fileName: file, functionName: function)
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalledExpectation.fulfill()
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, file)
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: rxDisposeBag!)
        
        log.report(logDetail: logDetail)
        wait(for: [isCalledExpectation], timeout: 2)
    }
}
