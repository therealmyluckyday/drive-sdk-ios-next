//
//  PersistantQueue.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 22/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift
import OSLog

#if canImport(BackgroundTasks)
import BackgroundTasks
#endif

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
       if let stopTripChunk = lastTripChunk, tripChunkSentCounter < 1 {
            lastTripChunk = nil
            self.providerTrip.onNext(stopTripChunk)
            
            if #available(iOS 13.0, *) {
                self.cancelScheduleBGTask()
            }
        }
    }
    
    func sendTripChunk(tripChunk: TripChunk) {
        tripChunkSentCounter = tripChunkSentCounter + 1
        self.providerTrip.onNext(tripChunk)
    }
    
    func sendLastTripChunk(tripChunk: TripChunk) {
        lastTripChunk = tripChunk
        
        if #available(iOS 13.0, *) {
            self.scheduleBGTask(lastTripChunk: tripChunk)
        }
        self.sendNextTripChunk()
    }
    
    @available(iOS 13.0, *)
    func cancelScheduleBGTask() {
        Log.print("[BGTASK]  CancelScheduleBGTask")
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: BGAppTaskRequestIdentifier)
    }
    
    @available(iOS 13.0, *)
    func scheduleBGTask(lastTripChunk: TripChunk) {
        Log.print("[BGTASK] ScheduleBGTask")
        do {
            let request = BGProcessingTaskRequest(identifier: BGAppTaskRequestIdentifier)//tripChunkSentCounter
            request.earliestBeginDate = Calendar.current.date(byAdding: .second, value: 60, to: Date())
            request.requiresNetworkConnectivity = true
            try BGTaskScheduler.shared.submit(request)
            let userDefaultsTexSDK = UserDefaults(suiteName: BGAppTaskRequestIdentifier)
            userDefaultsTexSDK?.setValue(lastTripChunk.serialize(), forKey: BGTaskDictionaryBodyKey)
            userDefaultsTexSDK?.setValue(lastTripChunk.tripInfos.baseUrl(), forKey: BGTaskBaseUrlKey)
            Log.print("[BGTASK]  scheduleBGTask Submitted task request \(tripChunkSentCounter)")
        } catch {
            Log.print("[BGTASK] Failed to submit BGTASK: \(error) ", type: .Error)
        }
    }
    
   
}
