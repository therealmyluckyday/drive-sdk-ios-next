//
//  LogRxFactoryTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 08/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift

@testable import TexDriveSDK

class LogRxFactoryTests: XCTestCase {
    private var rxDisposeBag : DisposeBag?
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
    }
    
    override func tearDown() {
        rxDisposeBag = nil
        super.tearDown()
    }
    
    // MARK: lazy var mainLogger: LogImplementation
    func testConfigureAndMainLoggerCanLog() {
        let regexPattern = ".*"
        let log = LogRxFactory()
        var isCalled = false
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: rxDisposeBag!)
        log.mainLogger.print("toto", type: LogType.Info, fileName: "superFile", functionName: "totoFunction")
        
        XCTAssert(isCalled)
    }
    
    func testConfigureAndMainLoggerCannotLog() {
        let regexPattern = "FALSE"
        let log = LogRxFactory()
        var isCalled = false
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: rxDisposeBag!)
        log.mainLogger.print("toto", type: LogType.Info, fileName: "superFile", functionName: "totoFunction")
        
        XCTAssertFalse(isCalled)
    }
    
    // MARK: func getLogger(file: String) -> LogDefaultImplementation
    func testConfigureAndGetLoggerCanLog() {
        let regexPattern = ".*"
        let log = LogRxFactory()
        var isCalled = false
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: rxDisposeBag!)
        log.getLogger(file: "toto").print("", type: LogType.Info, functionName: "toto")
        
        XCTAssert(isCalled)
    }
    
    func testConfigureAndGetLoggerCannotLog() {
        let regexPattern = "FALSE"
        let log = LogRxFactory()
        var isCalled = false
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: rxDisposeBag!)
        log.getLogger(file: "toto").print("", type: LogType.Info, functionName: "toto")
        
        XCTAssertFalse(isCalled)
    }
    
    // MARK: func configure(regex: NSRegularExpression, logType: LogType)
    func testConfigure() {
        let regexPattern = ".*"
        let log = LogRxFactory()
        var isCalled = false

        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: rxDisposeBag!)
        log.getLogger(file: "toto").print("", type: LogType.Info, functionName: "toto")
        log.mainLogger.print("toto", type: LogType.Info, fileName: "superFile", functionName: "totoFunction")
        
        XCTAssert(isCalled)
    }
    
    // MARK: func report(logDetail: LogDetail)
    func testReport() {
        let type = LogType.Info
        let detail = "sdodsfo"
        let file = "sdcidsfile"
        let log = LogRxFactory()
        let function = #function
        var isCalled = false
        let logDetail = LogMessage(type: type, detail: detail, fileName: file, functionName: function)
        
        log.rxLogOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                XCTAssertEqual(logDetail.message, detail)
                XCTAssertEqual(logDetail.fileName, file)
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: rxDisposeBag!)
        
        log.report(logDetail: logDetail)
        XCTAssert(isCalled)
    }
}
