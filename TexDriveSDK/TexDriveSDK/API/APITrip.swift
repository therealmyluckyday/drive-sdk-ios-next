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
    init(apiSessionManager: APISessionManager)
    func subscribe(providerTrip: PublishSubject<Trip>)
    func sendTrip(trip: Trip)
}

class APITrip: APITripProtocol {
    // MARK: Property
    private let disposeBag = DisposeBag()
    private let sessionManager : APISessionManager

    
    // MARK: APITripProtocol Protocol Method
    required init(apiSessionManager: APISessionManager) {
        self.sessionManager = apiSessionManager
    }
    
    func subscribe(providerTrip: PublishSubject<Trip>) {
        providerTrip.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in
            if let trip = event.element {
                self?.sendTrip(trip: trip)
            }
        }.disposed(by: disposeBag)
    }
    
    func sendTrip(trip: Trip) {
        self.sessionManager.put(dictionaryBody: trip.serialize())
    }
}
