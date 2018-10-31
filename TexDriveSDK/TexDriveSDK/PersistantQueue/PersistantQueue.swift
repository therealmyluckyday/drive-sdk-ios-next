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
    private var trip: Trip?
    private let disposeBag = DisposeBag()
    var providerTrip = PublishSubject<Trip>()
    
    
    // MARK: Lifecycle
    init(eventType: PublishSubject<EventType>, fixes: PublishSubject<Fix>) {
        eventType.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in
            if let eventType = event.element {
                
                if eventType == EventType.start {
                    self?.trip = Trip()
                }
                if let trip = self?.trip {
                    trip.append(eventType: eventType)
                    if eventType == EventType.stop {
                        self?.providerTrip.onNext(trip)
                        self?.trip = nil
                    }
                }

            }
        }.disposed(by: disposeBag)
        
        fixes.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in
            if let fix = event.element, let trip = self?.trip {
                trip.append(fix: fix)
                if trip.canUpload() {
                    self?.providerTrip.onNext(trip)
                    self?.trip = Trip(tripId: trip.tripId)
                }
            }
        }.disposed(by: disposeBag)
    }
}
