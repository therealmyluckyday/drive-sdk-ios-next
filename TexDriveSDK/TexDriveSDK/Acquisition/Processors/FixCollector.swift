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
    private let rxDisposeBag = DisposeBag()
    var rxErrorCollecting = PublishSubject<Error>() // @VHI currently do nothin
    private var trackers = [GenericTracker]()
    private var rxEventType: PublishSubject<EventType>
    private var rxFix: PublishSubject<Fix>
    private let rxScheduler: SerialDispatchQueueScheduler
    
    // MARK: LifeCycle
    init(eventsType: PublishSubject<EventType>, fixes: PublishSubject<Fix>, scheduler: SerialDispatchQueueScheduler) {
        print(fixes)
        rxFix = fixes
        rxEventType = eventsType
        rxScheduler = scheduler
    }
    
    // MARK: Public Method
    func collect<T>(tracker: T) where T: Tracker {
        self.subscribe(fromProviderFix: tracker.provideFix()) { [weak self](fix) in
            Log.print("fix datetime \(fix.description)")
            self?.rxFix.onNext(fix)
        }
        trackers.append(tracker)
    }
    
    func startCollect() {
        self.rxEventType.onNext(EventType.start)
        for tracker in trackers {
            tracker.enableTracking()
        }
    }
    
    func stopCollect() {
        self.rxEventType.onNext(EventType.stop)
//        self.rxEventType.onCompleted()
        for tracker in trackers {
            tracker.disableTracking()
        }
    }
    
    // MARK: private Method
    private func subscribe<T> (fromProviderFix: PublishSubject<Result<T>>?, resultClosure: @escaping ((T)->())) where T: Fix {
        if let proviveFix = fromProviderFix {
            proviveFix.asObservable().observeOn(rxScheduler).subscribe({ [weak self](event) in
                switch (event.element) {
                case .Success(let fix)?:
                    resultClosure(fix)
                    break
                case .Failure(let Error)?:
                    self?.rxErrorCollecting.onNext(Error)
                    break
                default:
                    break
                }
            })
                .disposed(by: rxDisposeBag)
        }
    }
}
