//
//  FakeLocationManager.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 16/09/2020.
//  Copyright © 2020 Axa. All rights reserved.
//

import UIKit
import CoreLocation
import OSLog

public class FakeLocationManager: LocationManager {
    let fakeTrackerLocationSensor: FakeLocationSensor
    public init() {
        self.fakeTrackerLocationSensor = FakeLocationSensor()
        super.init(autoModeLocationSensor: AutoModeLocationSensor(), locationSensor: fakeTrackerLocationSensor)
        #if targetEnvironment(simulator)
        #else
        self.trackerLocationSensor.clLocationManager.requestAlwaysAuthorization()
        #endif
    }
    
    public func loadTrip(intervalBetweenGPSPointInSecond: Double) {
        let myFakeTripPath = Bundle(for: FakeLocationManager.self).path(forResource: "trip_location_simulation", ofType: "csv")
        let background = DispatchQueue.global()
        background.async {
            do {
                let csvString = try String(contentsOfFile: myFakeTripPath!)
                let separator = CharacterSet.whitespacesAndNewlines
                let scanner = Scanner(string: csvString)
                scanner.charactersToBeSkipped = separator
                var line : NSString?
                var time = Date().timeIntervalSince1970 - 1000//- 90000 + 86400 39000
                var i = 0
                while scanner.scanUpToCharacters(from: separator, into: &line) {
                    if let line = line {
                        i = i + 1
                        if #available(iOS 13.0, *) {
                            time = self.sendLocationLineStringToSpeedFilter(line: line as String, time: time, intervalBetweenGPSPointInSecond: intervalBetweenGPSPointInSecond)
                        } else {
                            // Fallback on earlier versions
                        }
                        if i%10 == 0 {
                            os_log("                                     %{private}d" , log: OSLog.texDriveSDK, type: OSLogType.info, i)
                            
                        }
                    }
                }
            } catch {
                os_log("Error : %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(error)")
            }
        }
    }
    
    @available(iOS 13.0, *)
    private func sendLocationLineStringToSpeedFilter(line: String, time: Double, intervalBetweenGPSPointInSecond: Double) -> Double {
        let values = line.split(separator: Character(","))
        let latitude = Double(values[0])
        let longitude = Double(values[1])
        let accuracy = Double(values[2])
        let speed = Double(values[3])
        let bearing = Double(values[4])
        let altitude = Double(values[5])
        let delay = TimeInterval(Int(values[6])!)/1000
        let locationTime = TimeInterval(time)+delay
        let date = Date(timeIntervalSince1970: locationTime)
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!),
                                  altitude: CLLocationDistance(altitude!),
                                  horizontalAccuracy: CLLocationAccuracy(accuracy!), verticalAccuracy: CLLocationAccuracy(accuracy!), course: CLLocationDirection(bearing!), speed: CLLocationSpeed(speed!), timestamp: date)
        
        do {
            fakeTrackerLocationSensor.rxLocation.onNext(location)
            autoModeLocationSensor.rxLocation.onNext(location)
            if (time > 0) {Thread.sleep(forTimeInterval: intervalBetweenGPSPointInSecond)}
        }
        return locationTime
    }
}

extension Scanner {
  func scanDouble() -> Double? {
    var double: Double = 0
    return scanDouble(&double) ? double : nil
  }
}
