//
//  TripProgress.swift
//  TexDriveSDK
//
//  Created by A944VQ on 25/11/2020.
//

import Foundation

public struct TripProgress {
    public let tripId: TripId
    public let speed: Double
    public let distance: Double
    public let duration: TimeInterval
    
    public func roundDistanceValue() -> Double {
        let roundedValue: Int = ((Int)(self.distance/100)) * 100
        return Double(roundedValue)/1000.0
    }
    
    public func preciseDistanceValue() -> Double {
        return self.distance/1000.0
    }
}
