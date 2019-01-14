//
//  PersistantQueue.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 22/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift

struct Queue <T> {
    private(set) var elements = [T]()
    mutating func pop() -> T? {
        if let value = elements.first {
            elements.removeFirst()
            return value
        }
        return nil
    }
    
    mutating func push(element: T) {
        elements.append(element)
    }
}

class PersistantQueue {
    // MARK: Property
    private var trip: TripChunk?
    private var tripChunkSent: TripChunk?
    private var tripChunkWaitingQueue = Queue<TripChunk>()
    private let rxDisposeBag = DisposeBag()
    var providerTrip = PublishSubject<TripChunk>()
    let tripInfos: TripInfos
    
    // MARK: Lifecycle
    init(eventType: PublishSubject<EventType>, fixes: PublishSubject<Fix>, scheduler: SerialDispatchQueueScheduler, rxTripId: PublishSubject<TripId>, tripInfos: TripInfos, rxTripChunkSent: PublishSubject<Result<TripId>>) {
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
                        self?.tripChunkSent = trip
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
                    self?.tripChunkSent = trip
                    self?.providerTrip.onNext(trip)
                    self?.trip = TripChunk(tripId: trip.tripId, tripInfos: tripInfos)
                }
            }
        }.disposed(by: rxDisposeBag)
        
        rxTripChunkSent.asObservable().observeOn(scheduler).subscribe { [weak self](event) in
            if let result = event.element {
                switch result {
                case .Success(let tripId):
                    print("SUCCESS")
                    self?.sendNextTripChunk()
                    break
                case .Failure(let error):
                    print("ERROR")
                    self?.sendNextTripChunk()
                    break
                }
            }
            }.disposed(by: rxDisposeBag)
    }
    
    func sendNextTripChunk() {
        if let tripChunk = self.tripChunkWaitingQueue.pop() {
            self.tripChunkSent = tripChunk
            self.providerTrip.onNext(tripChunk)
        }
        else {
            self.tripChunkSent = nil
        }
    }
}
