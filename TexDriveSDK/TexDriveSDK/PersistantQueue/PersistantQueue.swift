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
    
    func isEmpty() -> Bool {
        return elements.isEmpty
    }
}

class PersistantQueue {
    // MARK: Property
    var tripChunkSent: TripChunk?
    private var tripChunkWaitingQueue = Queue<TripChunk>()
    private var currentTripChunk: TripChunk?
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
                    self?.currentTripChunk = aTrip
                    rxTripId.onNext(aTrip.tripId)
                }
                if let trip = self?.currentTripChunk {
                    trip.append(eventType: eventType)
                    if eventType == EventType.stop {
                        self?.sendTripChunk(tripChunk: trip)
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
                switch result {
                case .Success(let tripId):
                    self?.sendNextTripChunk()
                    break
                case .Failure(let error):
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
    
    func sendTripChunk(tripChunk: TripChunk) {
        self.tripChunkWaitingQueue.push(element: tripChunk)
        if self.tripChunkSent == nil {
            self.sendNextTripChunk()
        }
    }
}
