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
    private var rxDisposeBag : DisposeBag?
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        rxDisposeBag = nil
        super.tearDown()
    }
    
    // MARK: static func print(_ description: String, type: LogType, fileName: String, functionName: String)
    func testPrintConfigureAcceptAllWithFunctionTypeError() {
        let regexPattern = ".*"
        let description = "TOTO"
        let type = LogType.Error
        let file = #file
        let function = #function
        let loggerFactory = LogRx()
        
        Log.configure(logger: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rxLogOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                XCTAssertEqual(logDetail.message, description)
                XCTAssertEqual(logDetail.fileName, "LogTests.swift")
                XCTAssertEqual(logDetail.type, LogType.Error)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: rxDisposeBag!)
        
        Log.print(description, type: type, fileName: file, functionName: function)

        XCTAssert(isCalled)
    }
    
    func testPrintConfigureAcceptAllWithFunctionTypeWarning() {
        let regexPattern = ".*"
        let description = "TOTO"
        let type = LogType.Warning
        let file = #file
        let function = #function
        let loggerFactory = LogRx()
        
        Log.configure(logger: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rxLogOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, description)
                XCTAssertEqual(logDetail.fileName, "LogTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: rxDisposeBag!)
        
        Log.print(description, type: type, fileName: file, functionName: function)

        XCTAssert(isCalled)
    }
    
    func testPrintConfigureAcceptAllWithFunctionTypeInfo() {
        let regexPattern = ".*"
        let description = "TOTO"
        let type = LogType.Info
        let file = #file
        let function = #function
        let loggerFactory = LogRx()
        
        Log.configure(logger: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rxLogOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, description)
                XCTAssertEqual(logDetail.fileName, "LogTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: rxDisposeBag!)
        
        Log.print(description, type: type, fileName: file, functionName: function)
        
        XCTAssert(isCalled)
    }
    
    func testPrintConfigureAcceptErrorWithFunctionTypeInfo() {
        let regexPattern = ".*"
        let description = "TOTO"
        let type = LogType.Info
        let file = #file
        let function = #function
        let loggerFactory = LogRx()
        
        Log.configure(logger: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Error)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rxLogOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: rxDisposeBag!)
        
        Log.print(description, type: type, fileName: file, functionName: function)
        
        XCTAssertFalse(isCalled)
    }
    
    func testPrintConfigureAcceptWarningWithFunctionTypeInfo() {
        let regexPattern = ".*"
        let description = "TOTO"
        let type = LogType.Info
        let file = #file
        let function = #function
        let loggerFactory = LogRx()
        
        Log.configure(logger: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Warning)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rxLogOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: rxDisposeBag!)
        
        Log.print(description, type: type, fileName: file, functionName: function)
        
        XCTAssertFalse(isCalled)
    }
    
    func testPrintConfigureAcceptErrorWithFunctionTypeWarning() {
        let regexPattern = ".*"
        let description = "TOTO"
        let type = LogType.Warning
        let file = #file
        let function = #function
        let loggerFactory = LogRx()
        
        Log.configure(logger: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Error)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rxLogOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: rxDisposeBag!)
        
        Log.print(description, type: type, fileName: file, functionName: function)
        
        XCTAssertFalse(isCalled)
    }

    // MARK: static func configure(regex: NSRegularExpression, logType: LogType)
    func testConfigureRegExNotCalled() {
        let regexPattern = ".*TATA.*"
        let description = "TOTO"
        let type = LogType.Info
        let file = #file
        let function = #function
        let loggerFactory = LogRx()
        
        Log.configure(logger: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rxLogOutput.asObservable().subscribe { (event) in
            isCalled = true
            }.disposed(by: rxDisposeBag!)
        
        Log.print(description, type: type, fileName: file, functionName: function)
        
        XCTAssertFalse(isCalled)
    }
    
    func testConfigureRegExCalled() {
        let regexPattern = ".*LogTests.*"
        let description = "TATA"
        let type = LogType.Info
        let file = #file
        let function = #function
        let loggerFactory = LogRx()
        
        Log.configure(logger: loggerFactory)
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Info)
        } catch {
            XCTAssertFalse(true)
        }
        
        var isCalled = false
        loggerFactory.rxLogOutput.asObservable().subscribe { (event) in
            if let logDetail = event.element {
                isCalled = true
                
                XCTAssertEqual(logDetail.message, description)
                XCTAssertEqual(logDetail.fileName, "LogTests.swift")
                XCTAssertEqual(logDetail.type, type)
                XCTAssertEqual(logDetail.functionName, function)
            }
            }.disposed(by: rxDisposeBag!)
        
        Log.print(description, type: type, fileName: file, functionName: function)
        
        XCTAssert(isCalled)
    }
}
