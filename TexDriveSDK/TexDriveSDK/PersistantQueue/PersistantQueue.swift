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
import KeychainAccess

#if canImport(BackgroundTasks)
import BackgroundTasks
#endif

let BGAppTaskRequestIdentifier = "com.texdrivesdk.processing.stop"
let BGTaskDictionaryBodyKey = "dictionaryBody"
let BGTaskBaseUrlKey = "baseUrl"

class PersistantQueue {
    // MARK: Property
    private var currentTripChunk: TripChunk?
    private let rxDisposeBag = DisposeBag()
    var providerTrip = PublishSubject<TripChunk>()
    var providerOrderlyTrip = PublishSubject<(String, String)>()
    let tripInfos: TripInfos
    var tripChunkSentCounter = 0
    var lastTripChunk: TripChunk?
    let isUsingOrderlyTripChunk = false
    var tripChunkDatabase: TripChunkDatabase? = nil
    
    // MARK: Lifecycle
    init(eventType: PublishSubject<EventType>, fixes: PublishSubject<Fix>, scheduler: SerialDispatchQueueScheduler, rxTripId: PublishSubject<TripId>, tripInfos: TripInfos, rxTripChunkSent: PublishSubject<Result<TripId>>) {
        self.tripInfos = tripInfos
        eventType.asObservable().observe(on: scheduler).subscribe { [weak self](event) in
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
        
        fixes.asObservable().observe(on: scheduler).subscribe { [weak self](event) in
            if let fix = event.element, let trip = self?.currentTripChunk {
                trip.append(fix: fix)
                if let tripInfos = self?.tripInfos, trip.canUpload() {
                    let tripChunk = TripChunk(tripId: trip.tripId, tripInfos: tripInfos)
                    self?.currentTripChunk = tripChunk
                    self?.sendTripChunk(tripChunk: trip)
                }
            }
            }.disposed(by: rxDisposeBag)
        
        rxTripChunkSent.asObservable().observe(on: scheduler).subscribe { [weak self](event) in
            if let result = event.element {
                if let counter = self?.tripChunkSentCounter {
                    self?.tripChunkSentCounter = counter - 1
                    Log.print("tripChunkSentCounter \(counter)")
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
        
        tripChunkDatabase = TripChunkDatabase(path: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!, name: "TripChunkDatabase.dbs")
    }
    
    func sendNextTripChunk() {
        Log.print("tripChunkSentCounter \(tripChunkSentCounter)")
        if isUsingOrderlyTripChunk,
           tripChunkDatabase != nil,
           let (payload, baseurl) = tripChunkDatabase?.pop() {
            // Retrieve TripChunk Information
            providerOrderlyTrip.onNext((payload, baseurl))
        } else {
            if let stopTripChunk = lastTripChunk, tripChunkSentCounter < 1 {
                 lastTripChunk = nil
                 
                 if #available(iOS 13.0, *) {
                     self.cancelScheduleBGTask()
                 }
                 self.providerTrip.onNext(stopTripChunk)
            }
        }
    }
    
    func sendTripChunk(tripChunk: TripChunk) {
        tripChunkSentCounter = tripChunkSentCounter + 1
        Log.print("tripChunkSentCounter \(tripChunkSentCounter)")
        if isUsingOrderlyTripChunk && tripChunkDatabase != nil  {
            // Save TripChunk Information
            tripChunkDatabase?.insert(tripchunk: tripChunk)
            //if tripChunkSentCounter == 1 {
                sendNextTripChunk()
            //}
            
        } else {
            self.providerTrip.onNext(tripChunk)
        }
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
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
    
    @available(iOS 13.0, *)
    func scheduleBGTask(lastTripChunk: TripChunk) {
        Log.print("[BGTASK] ScheduleBGTask")
        do {
            saveTripChunk(lastTripChunk: lastTripChunk)
            let request = BGProcessingTaskRequest(identifier: BGAppTaskRequestIdentifier)//tripChunkSentCounter
            request.earliestBeginDate = Calendar.current.date(byAdding: .second, value: 60, to: Date())
            request.requiresNetworkConnectivity = true
            try BGTaskScheduler.shared.submit(request)
            Log.print("[BGTASK]  scheduleBGTask Submitted task request \(tripChunkSentCounter)")
        } catch {
            #if targetEnvironment(simulator)
            #else
            Log.print("[BGTASK] Failed to submit BGTASK: \(error) ", type: .Error)
            #endif
        }
    }
    
    func saveTripChunk(lastTripChunk: TripChunk) {
        do {
            let keychain = Keychain(service: BGAppTaskRequestIdentifier)
            keychain[data: BGTaskDictionaryBodyKey] = try JSONSerialization.data(withJSONObject: lastTripChunk.serialize(), options:[])
            keychain[string: BGTaskBaseUrlKey] = lastTripChunk.tripInfos.baseUrl()
        } catch  {
            Log.print("[BGTASK] Failed to save data: \(error) ", type: .Error)
        }
    }
   
}

