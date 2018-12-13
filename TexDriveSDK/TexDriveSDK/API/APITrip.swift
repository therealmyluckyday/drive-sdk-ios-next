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
}

class APITrip: APITripProtocol {
    // MARK: Property
    private let sessionManager : APISessionManagerProtocol

    
    // MARK: APITripProtocol Protocol Method
    required init(apiSessionManager: APISessionManagerProtocol) {
        self.sessionManager = apiSessionManager
    }
    
    func sendTrip(trip: TripChunk) {
        self.sessionManager.put(dictionaryBody: trip.serialize())
    }
}
