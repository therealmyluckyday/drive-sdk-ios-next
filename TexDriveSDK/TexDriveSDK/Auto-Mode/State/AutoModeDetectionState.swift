//
//  AutoModeDetectionState.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 17/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift

protocol AutoModeDetectionStateProtocol {
    func start()
    func stop()
    func drive()
    func enable()
    func disable()
}


public class AutoModeDetectionState: NSObject, AutoModeDetectionStateProtocol {
    // MARK : Property
    weak var context: AutoModeContextProtocol?
    
    // MARK : LifeCycle
    init(context: AutoModeContextProtocol) {
        self.context = context
        super.init()
        self.configure()
    }
    
    // MARK : AutoModeDetectionStateProtocol
    func configure() {}
    func start() {}
    func stop() {}
    func drive() {}
    func enable() {}
    func disable() {}
}
