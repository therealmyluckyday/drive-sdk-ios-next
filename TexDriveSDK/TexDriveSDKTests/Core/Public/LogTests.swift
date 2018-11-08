//
//  LogTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 08/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import TexDriveSDK

class LogTests: XCTestCase {
    private var disposeBag : DisposeBag?
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        disposeBag = nil
        super.tearDown()
    }
    
    // MARK: static func print(_ description: String, type: LogType, file: String, function: String)
    func testPrintConfigureAcceptAllWithFunctionTypeError() {
        let regexPattern = ".*"
        let description = "TOTO"
        let type = LogType.Error
        let file = #file
        let function = #function
        let loggerFactory = LogRxFactory()
        
        Log.configure(loggerFactory: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rx_logOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                XCTAssertEqual(logDetail.detail, description)
                XCTAssertEqual(logDetail.file, "LogTests.swift")
                XCTAssertEqual(logDetail.type, LogType.Error)
                XCTAssertEqual(logDetail.function!, function)
            }
            }.disposed(by: disposeBag!)
        
        Log.print(description, type: type, file: file, function: function)

        XCTAssert(isCalled)
    }
    
    func testPrintConfigureAcceptAllWithFunctionTypeWarning() {
        let regexPattern = ".*"
        let description = "TOTO"
        let type = LogType.Warning
        let file = #file
        let function = #function
        let loggerFactory = LogRxFactory()
        
        Log.configure(loggerFactory: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rx_logOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.detail, description)
                XCTAssertEqual(logDetail.file, "LogTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.function!, function)
            }
            }.disposed(by: disposeBag!)
        
        Log.print(description, type: type, file: file, function: function)

        XCTAssert(isCalled)
    }
    
    func testPrintConfigureAcceptAllWithFunctionTypeInfo() {
        let regexPattern = ".*"
        let description = "TOTO"
        let type = LogType.Info
        let file = #file
        let function = #function
        let loggerFactory = LogRxFactory()
        
        Log.configure(loggerFactory: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rx_logOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.detail, description)
                XCTAssertEqual(logDetail.file, "LogTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.function!, function)
            }
            }.disposed(by: disposeBag!)
        
        Log.print(description, type: type, file: file, function: function)
        
        XCTAssert(isCalled)
    }
    
    func testPrintConfigureAcceptErrorWithFunctionTypeInfo() {
        let regexPattern = ".*"
        let description = "TOTO"
        let type = LogType.Info
        let file = #file
        let function = #function
        let loggerFactory = LogRxFactory()
        
        Log.configure(loggerFactory: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Error)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rx_logOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: disposeBag!)
        
        Log.print(description, type: type, file: file, function: function)
        
        XCTAssertFalse(isCalled)
    }
    
    func testPrintConfigureAcceptWarningWithFunctionTypeInfo() {
        let regexPattern = ".*"
        let description = "TOTO"
        let type = LogType.Info
        let file = #file
        let function = #function
        let loggerFactory = LogRxFactory()
        
        Log.configure(loggerFactory: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Warning)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rx_logOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: disposeBag!)
        
        Log.print(description, type: type, file: file, function: function)
        
        XCTAssertFalse(isCalled)
    }
    
    func testPrintConfigureAcceptErrorWithFunctionTypeWarning() {
        let regexPattern = ".*"
        let description = "TOTO"
        let type = LogType.Warning
        let file = #file
        let function = #function
        let loggerFactory = LogRxFactory()
        
        Log.configure(loggerFactory: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Error)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rx_logOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: disposeBag!)
        
        Log.print(description, type: type, file: file, function: function)
        
        XCTAssertFalse(isCalled)
    }

    // MARK: static func defaultLogger(file: String) -> LogDefaultImplementation
    func testdefaultLoggerCorrectFile() {
        let regexPattern = ".*"
        let description = "TATA"
        let type = LogType.Error
        let file = "/LOVELYFILE.toto"
        let function = "superFunction"
        let loggerFactory = LogRxFactory()
        
        Log.configure(loggerFactory: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rx_logOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.detail, description)
                XCTAssertEqual(logDetail.file, "LOVELYFILE.toto")
                XCTAssertEqual(logDetail.type, LogType.Error)
                XCTAssertEqual(logDetail.function!, function)
            }
            }.disposed(by: disposeBag!)
        
        let log = Log.defaultLogger(file: file)
        log.print(description, type: type, function: function)
        
        XCTAssert(isCalled)
    }
    // MARK: static func configure(regex: NSRegularExpression, logType: LogType)
    func testConfigureRegExNotCalled() {
        let regexPattern = ".*TATA.*"
        let description = "TOTO"
        let type = LogType.Info
        let file = #file
        let function = #function
        let loggerFactory = LogRxFactory()
        
        Log.configure(loggerFactory: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rx_logOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: disposeBag!)
        
        Log.print(description, type: type, file: file, function: function)
        
        XCTAssertFalse(isCalled)
    }
    
    func testConfigureRegExCalled() {
        let regexPattern = ".*LogTests.*"
        let description = "TATA"
        let type = LogType.Info
        let file = #file
        let function = #function
        let loggerFactory = LogRxFactory()
        
        Log.configure(loggerFactory: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rx_logOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.detail, description)
                XCTAssertEqual(logDetail.file, "LogTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.function!, function)
            }
            }.disposed(by: disposeBag!)
        
        Log.print(description, type: type, file: file, function: function)
        
        XCTAssert(isCalled)
    }
}
