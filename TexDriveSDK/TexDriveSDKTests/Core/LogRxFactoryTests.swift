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
    private var disposeBag : DisposeBag?
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
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
        
        log.rx_logOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: disposeBag!)
        log.mainLogger.print("toto", type: LogType.Info, file: "superFile", function: "totoFunction")
        
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
        
        log.rx_logOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: disposeBag!)
        log.mainLogger.print("toto", type: LogType.Info, file: "superFile", function: "totoFunction")
        
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
        
        log.rx_logOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: disposeBag!)
        log.getLogger(file: "toto").print("", type: LogType.Info, function: "toto")
        
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
        
        log.rx_logOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: disposeBag!)
        log.getLogger(file: "toto").print("", type: LogType.Info, function: "toto")
        
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
        
        log.rx_logOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: disposeBag!)
        log.getLogger(file: "toto").print("", type: LogType.Info, function: "toto")
        log.mainLogger.print("toto", type: LogType.Info, file: "superFile", function: "totoFunction")
        
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
        let logDetail = LogDetail(type: type, detail: detail, file: file, function: function)
        
        log.rx_logOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                XCTAssertEqual(logDetail.detail, detail)
                XCTAssertEqual(logDetail.file, file)
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.function!, function)
            }
            }.disposed(by: disposeBag!)
        
        log.report(logDetail: logDetail)
        XCTAssert(isCalled)
    }
}
