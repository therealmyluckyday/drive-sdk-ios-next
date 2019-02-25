//
//  DisabledStateTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 20/02/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK
@testable import RxSwift

class DisabledStateTests: XCTestCase {
    var disposeBag = DisposeBag()
    let context = StubAutoModeContextProtocol()
   
    func testEnable() {
        let state = DisabledState(context: context)
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is StandbyState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        state.enable()
        wait(for: [expectation], timeout: 1)
    }
    
    func testStart() {
        let state = DisabledState(context: context)
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is StandbyState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        state.start()
        wait(for: [expectation], timeout: 1)
    }
    
    func testDrive() {
        let state = DisabledState(context: context)
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is DrivingState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        state.drive()
        wait(for: [expectation], timeout: 1)
    }
}
