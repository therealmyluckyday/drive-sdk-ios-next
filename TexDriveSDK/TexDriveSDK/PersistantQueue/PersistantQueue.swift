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
    private var currentTripChunk: TripChunk?
    private let rxDisposeBag = DisposeBag()
    var providerTrip = PublishSubject<TripChunk>()
    let tripInfos: TripInfos
    var tripChunkSentCounter = 0
    var lastTripChunk: TripChunk?
    
    // MARK: Lifecycle
    init(eventType: PublishSubject<EventType>, fixes: PublishSubject<Fix>, scheduler: SerialDispatchQueueScheduler, rxTripId: PublishSubject<TripId>, tripInfos: TripInfos, rxTripChunkSent: PublishSubject<Result<TripId>>) {
        self.tripInfos = tripInfos
        eventType.asObservable().observeOn(scheduler).subscribe { [weak self](event) in
            if let eventType = event.element {
                if let tripInfos = self?.tripInfos, eventType == EventType.start {
                    self?.tripChunkSentCounter = 0
                    let aTrip = TripChunk(tripInfos: tripInfos)
                    self?.currentTripChunk = aTrip
                    self?.lastTripChunk = nil
                    Log.print("New TRIP \(aTrip.tripId) ")
                    rxTripId.onNext(aTrip.tripId)
                }
                if let trip = self?.currentTripChunk {
                    trip.append(eventType: eventType)
                    if eventType == EventType.stop {
                        self?.sendLastTripChunk(tripChunk: trip)
                        self?.currentTripChunk = nil
                    }
                }
            }
            }.disposed(by: rxDisposeBag)
        
        fixes.asObservable().observeOn(scheduler).subscribe { [weak self](event) in
            if let fix = event.element, let trip = self?.currentTripChunk {
                trip.append(fix: fix)
                if let tripInfos = self?.tripInfos, trip.canUpload() {
                    let tripChunk = TripChunk(tripId: trip.tripId, tripInfos: tripInfos)
                    self?.currentTripChunk = tripChunk
                    self?.sendTripChunk(tripChunk: trip)
                }
            }
            }.disposed(by: rxDisposeBag)
        
        rxTripChunkSent.asObservable().observeOn(scheduler).subscribe { [weak self](event) in
            if let result = event.element {
                if let counter = self?.tripChunkSentCounter {
                    self?.tripChunkSentCounter = counter - 1
                }
                switch result {
                case .Success(_):
                    self?.sendNextTripChunk()
                    break
                case .Failure(_):
                    self?.sendNextTripChunk()
                    break
                }
            }
            }.disposed(by: rxDisposeBag)
    }
    
    func sendNextTripChunk() {
        Log.print("sendNextTripChunk ")
        if let stopTripChunk = lastTripChunk, tripChunkSentCounter < 1 {
            lastTripChunk = nil
            self.providerTrip.onNext(stopTripChunk)
        }

    }
    
    func sendTripChunk(tripChunk: TripChunk) {
        Log.print("sendTripChunk \(tripChunk.count) ")
        tripChunkSentCounter = tripChunkSentCounter + 1
        self.providerTrip.onNext(tripChunk)
    }
    
    func sendLastTripChunk(tripChunk: TripChunk) {
        lastTripChunk = tripChunk
        self.sendNextTripChunk()
    }
}
