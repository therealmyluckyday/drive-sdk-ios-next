//
//  FixCollector.swift
//  TexDriveSDK
//
//  Created by Axa on 13/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import RxSwift

class FixCollector {
    // MARK: Property
    private let disposeBag = DisposeBag()
    private var rx_errorCollecting = PublishSubject<Error>()
    private var trackers = [GenericTracker]()
    
    // MARK: LifeCycle
    
    func collect<T>(tracker: T) where T: Tracker {
        self.subscribe(fromProviderFix: tracker.provideFix()) { (fix) in
            print("fix datetime \(fix.description)")
        }
        trackers.append(tracker)
    }
    
    // MARK: Public Method
    func startCollect() {
        for tracker in trackers {
            tracker.enableTracking()
        }
    }
    
    func stopCollect() {
        for tracker in trackers {
            tracker.disableTracking()
        }
    }
    
    // MARK: private Method
    private func subscribe<T> (fromProviderFix: PublishSubject<Result<T>>?, resultClosure: @escaping ((T)->())) where T: Fix {
        if let proviveFix = fromProviderFix {
            proviveFix.asObservable().subscribe({ [weak self](event) in
                switch (event.element) {
                case .Success(let fix)?:
                    resultClosure(fix)
                    break
                case .Failure(let Error)?:
                    self?.rx_errorCollecting.onNext(Error)
                    break
                default:
                    break
                }
            })
                .disposed(by: disposeBag)
        }
    }
}
