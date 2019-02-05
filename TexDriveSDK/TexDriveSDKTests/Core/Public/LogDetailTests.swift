//
//  LogDetailTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 08/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK

class LogDetailTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    // MARK: init(type currentType: LogType, detail description: String, file fileWithPath: String, function currentFunction: String?)
    func testInitWithFunction() {
        let type = LogType.Info
        let detail = "myDetail"
        let file = "/myFile.tata"
        let function = #function
        
        let logDetail = LogMessage(type: type, detail: detail, fileName: file, functionName: function)
        
        XCTAssertNotNil(logDetail.functionName)
        XCTAssertEqual(logDetail.type, type)
        XCTAssertEqual(logDetail.message, detail)
        XCTAssertEqual(logDetail.fileName, "myFile.tata")
        XCTAssertEqual(logDetail.functionName, function)
    }
    
    // MARK: class func cleanPathForFile(fileWithPath: String) -> String
    func testcleanPathForFileWithFolder() {
        let file = "/myFile.tata"
        
        let result = LogMessage.cleanPathForFile(fileWithPath: file)
        
        XCTAssertEqual(result, "myFile.tata")
    }
    
    func testcleanPathForFileWithoutFolder() {
        let file = "myFile.tata"
        
        let result = LogMessage.cleanPathForFile(fileWithPath: file)
        
        XCTAssertEqual(result, "myFile.tata")
    }
    
    // MARK: func canLog(regex: NSRegularExpression, logType: LogType) -> Bool
    func testCanLogRegexOkLogTypeInfoWithLogTypeInfo() {
        let type = LogType.Info
        let detail = "myDetail"
        let file = "/myFile.tata"
        let function = #function
        let logDetail = LogMessage(type: type, detail: detail, fileName: file, functionName: function)
        let regexPattern = ".*"
        let logTypeTest = LogType.Info
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            
            let result = logDetail.canLog(regex: regex, logType: logTypeTest)
            
            XCTAssertTrue(result)
        } catch {
            XCTAssertFalse(true)
        }
    }
    
    func testCanLogRegexNotOkLogTypeInfoWithLogTypeInfo() {
        let type = LogType.Info
        let detail = "myDetail"
        let file = "/myFile.tata"
        let function = #function
        let logDetail = LogMessage(type: type, detail: detail, fileName: file, functionName: function)
        let regexPattern = ".*TOTO.*"
        let logTypeTest = LogType.Info
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            
            let result = logDetail.canLog(regex: regex, logType: logTypeTest)
            
            XCTAssertFalse(result)
        } catch {
            XCTAssertFalse(true)
        }
    }
    
    
    func testCanLogRegexNotOkLogTypeWarningWithLogTypeInfo() {
        let type = LogType.Info
        let detail = "myDetail"
        let file = "/myFile.tata"
        let function = #function
        let logDetail = LogMessage(type: type, detail: detail, fileName: file, functionName: function)
        let regexPattern = ".*"
        let logTypeTest = LogType.Warning
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            
            let result = logDetail.canLog(regex: regex, logType: logTypeTest)
            
            XCTAssertFalse(result)
        } catch {
            XCTAssertFalse(true)
        }
    }
    
    func testCanLogRegexNotOkLogTypeErrorWithLogTypeInfo() {
        let type = LogType.Info
        let detail = "myDetail"
        let file = "/myFile.tata"
        let function = #function
        let logDetail = LogMessage(type: type, detail: detail, fileName: file, functionName: function)
        let regexPattern = ".*"
        let logTypeTest = LogType.Error
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            
            let result = logDetail.canLog(regex: regex, logType: logTypeTest)
            
            XCTAssertFalse(result)
        } catch {
            XCTAssertFalse(true)
        }
    }
    
    func testCanLogRegexOkLogTypeWarningWithLogTypeWarning() {
        let type = LogType.Warning
        let detail = "myDetail"
        let file = "/myFile.tata"
        let function = #function
        let logDetail = LogMessage(type: type, detail: detail, fileName: file, functionName: function)
        let regexPattern = ".*"
        let logTypeTest = LogType.Warning
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            
            let result = logDetail.canLog(regex: regex, logType: logTypeTest)
            
            XCTAssertTrue(result)
        } catch {
            XCTAssertFalse(true)
        }
    }
    func testCanLogRegexOkLogTypeErrorWithLogTypeError() {
        let type = LogType.Error
        let detail = "myDetail"
        let file = "/myFile.tata"
        let function = #function
        let logDetail = LogMessage(type: type, detail: detail, fileName: file, functionName: function)
        let regexPattern = ".*"
        let logTypeTest = LogType.Error
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            
            let result = logDetail.canLog(regex: regex, logType: logTypeTest)
            
            XCTAssertTrue(result)
        } catch {
            XCTAssertFalse(true)
        }
    }
    func testCanLogRegexOkLogTypeWarningWithLogTypeError() {
        let type = LogType.Error
        let detail = "myDetail"
        let file = "/myFile.tata"
        let function = #function
        let logDetail = LogMessage(type: type, detail: detail, fileName: file, functionName: function)
        let regexPattern = ".*"
        let logTypeTest = LogType.Warning
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            
            let result = logDetail.canLog(regex: regex, logType: logTypeTest)
            
            XCTAssertTrue(result)
        } catch {
            XCTAssertFalse(true)
        }
    }
    func testCanLogRegexOkLogTypeInfoWithLogTypeError() {
        let type = LogType.Error
        let detail = "myDetail"
        let file = "/myFile.tata"
        let function = #function
        let logDetail = LogMessage(type: type, detail: detail, fileName: file, functionName: function)
        let regexPattern = ".*"
        let logTypeTest = LogType.Info
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            
            let result = logDetail.canLog(regex: regex, logType: logTypeTest)
            
            XCTAssertTrue(result)
        } catch {
            XCTAssertFalse(true)
        }
    }
}
