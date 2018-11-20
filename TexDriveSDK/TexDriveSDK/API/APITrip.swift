//
//  APITrip.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 23/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift

protocol APITripProtocol {
    init(apiSessionManager: APISessionManagerProtocol)
    func subscribe(providerTrip: PublishSubject<Trip>, scheduler: ImmediateSchedulerType)
}

class APITrip: APITripProtocol {
    // MARK: Property
    private let disposeBag = DisposeBag()
    private let sessionManager : APISessionManagerProtocol

    
    // MARK: APITripProtocol Protocol Method
    required init(apiSessionManager: APISessionManagerProtocol) {
        self.sessionManager = apiSessionManager
    }
    
    func subscribe(providerTrip: PublishSubject<Trip>, scheduler: ImmediateSchedulerType = MainScheduler.asyncInstance) {
        providerTrip.asObservable().observeOn(scheduler).subscribe { [weak self](event) in
            if let trip = event.element {
                self?.sendTrip(trip: trip)
            }
        }.disposed(by: disposeBag)
    }
    
    func sendTrip(trip: Trip) {
        self.sessionManager.put(dictionaryBody: trip.serialize())
    }
}
