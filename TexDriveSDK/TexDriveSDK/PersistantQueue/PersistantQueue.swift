//
//  PersistantQueue.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 22/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift

class PersistantQueue {
    // MARK: Property
    private var trip: TripChunk?
    private let rxDisposeBag = DisposeBag()
    var providerTrip = PublishSubject<TripChunk>()
    
    
    // MARK: Lifecycle
    init(eventType: PublishSubject<EventType>, fixes: PublishSubject<Fix>, scheduler: SerialDispatchQueueScheduler) {
        eventType.asObservable().observeOn(scheduler).subscribe { [weak self](event) in
            if let eventType = event.element {
                
                if eventType == EventType.start {
                    self?.trip = TripChunk()
                }
                if let trip = self?.trip {
                    trip.append(eventType: eventType)
                    if eventType == EventType.stop {
                        self?.providerTrip.onNext(trip)
                        self?.trip = nil
                    }
                }

            }
        }.disposed(by: rxDisposeBag)
        
        fixes.asObservable().observeOn(scheduler).subscribe { [weak self](event) in
            if let fix = event.element, let trip = self?.trip {
                trip.append(fix: fix)
                if trip.canUpload() {
                    self?.providerTrip.onNext(trip)
                    self?.trip = TripChunk(tripId: trip.tripId)
                }
            }
        }.disposed(by: rxDisposeBag)
    }
}
