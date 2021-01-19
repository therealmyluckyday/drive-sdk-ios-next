//
//  TripRecorderiOS13.swift
//  TexDriveSDK
//
//  Created by A944VQ on 15/12/2020.
//  Copyright © 2020 Axa. All rights reserved.
//


#if canImport(Swiftui)
import Foundation
import SwiftUI
import RxSwift

@available(iOS 13.0, *)
public class TripRecorderiOS13SwiftUI: TripRecorder, ObservableObject {
    @Published public var tripProgress: TripProgress?
    @Published public var isRecordingiOS13 = false
    @Published public var isDrivingiOS13 = false
    
    public override func start(date: Date = Date()) {
        isRecordingiOS13 = true
         super.start()
    }
    
    public override func stop() {
        isRecordingiOS13 = false
        super.stop()
    }
    
    override func update(tripProgress: TripProgress) {
        //print("UPDATE")
        self.tripProgress = tripProgress
    }
    
    public override func configureAutoMode(_ scheduler: SerialDispatchQueueScheduler = MainScheduler.instance) {
        autoMode?.rxIsDriving.asObserver().observeOn(scheduler).subscribe { [weak self](event) in
            if let isDriving = event.element {
                self?.isDrivingiOS13 = isDriving
                if isDriving {
                    self?.start()
                } else {
                    self?.stop()
                }
            }
            }.disposed(by: rxDisposeBag)
    }
}

#endif
