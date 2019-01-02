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
    let tripInfos: TripInfos
    
    // MARK: Lifecycle
    init(eventType: PublishSubject<EventType>, fixes: PublishSubject<Fix>, scheduler: SerialDispatchQueueScheduler, rxTripId: PublishSubject<TripId>, tripInfos: TripInfos) {
        self.tripInfos = tripInfos
        eventType.asObservable().observeOn(scheduler).subscribe { [weak self](event) in
            if let eventType = event.element {
                if let tripInfos = self?.tripInfos, eventType == EventType.start {
                    let aTrip = TripChunk(tripInfos: tripInfos)
                    self?.trip = aTrip
                    rxTripId.onNext(aTrip.tripId)
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
                if let tripInfos = self?.tripInfos, trip.canUpload() {
                    self?.providerTrip.onNext(trip)
                    self?.trip = TripChunk(tripId: trip.tripId, tripInfos: tripInfos)
                }
            }
        }.disposed(by: rxDisposeBag)
    }
}
