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
    private var rx_eventType: PublishSubject<EventType>
    private var rx_fix: PublishSubject<Fix>
    private let rx_scheduler: SerialDispatchQueueScheduler
    
    // MARK: LifeCycle
    init(eventsType: PublishSubject<EventType>, fixes: PublishSubject<Fix>, scheduler: SerialDispatchQueueScheduler) {
        print(fixes)
        rx_fix = fixes
        rx_eventType = eventsType
        rx_scheduler = scheduler
    }
    
    // MARK: Public Method
    func collect<T>(tracker: T) where T: Tracker {
        self.subscribe(fromProviderFix: tracker.provideFix()) { [weak self](fix) in
            Log.print("fix datetime \(fix.description)")
            self?.rx_fix.onNext(fix)
        }
        trackers.append(tracker)
    }
    
    func startCollect() {
        self.rx_eventType.onNext(EventType.start)
        for tracker in trackers {
            tracker.enableTracking()
        }
    }
    
    func stopCollect() {
        self.rx_eventType.onNext(EventType.stop)
//        self.rx_eventType.onCompleted()
        for tracker in trackers {
            tracker.disableTracking()
        }
    }
    
    // MARK: private Method
    private func subscribe<T> (fromProviderFix: PublishSubject<Result<T>>?, resultClosure: @escaping ((T)->())) where T: Fix {
        if let proviveFix = fromProviderFix {
            proviveFix.asObservable().observeOn(rx_scheduler).subscribe({ [weak self](event) in
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
