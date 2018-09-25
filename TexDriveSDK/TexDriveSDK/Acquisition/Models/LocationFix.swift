//
//  LocationFix.swift
//  TexDriveSDK
//
//  Created by Axa on 25/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

class LocationFix : Fix {
    
    var latitude : Double
    var longitude : Double
    var precision : Double
    var speed : Double
    var bearing : Double
    var altitude : Double
    
    init(fixId: String, timestamp: Date, latitude: Double = 0, longitude: Double = 0, precision: Double = 0, speed: Double = 0, bearing: Double = 0, altitude: Double = 0) {
        self.latitude = latitude
        self.longitude = longitude
        self.precision = precision
        self.speed = speed
        self.bearing = bearing
        self.altitude = altitude
        super.init(fixId: fixId, timestamp: timestamp)
    }
}
