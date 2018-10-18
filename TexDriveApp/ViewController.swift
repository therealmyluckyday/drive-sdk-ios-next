//
//  ViewController.swift
//  TexDriveApp
//
//  Created by Axa on 11/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import UIKit
import CoreLocation
import TexDriveSDK
import CallKit
import CoreMotion

class ViewController: UIViewController {

    var tripRecorder : TripRecorder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = User.Anonymous
        let locationfeature : TripRecorderFeature = TripRecorderFeature.Location(CLLocationManager())
        let batteryfeature : TripRecorderFeature = TripRecorderFeature.Battery(UIDevice.current)
        let phoneCallFeature : TripRecorderFeature = TripRecorderFeature.PhoneCall(CXCallObserver())
        let motionFeature : TripRecorderFeature = TripRecorderFeature.Motion(CMMotionManager())
        let features = [locationfeature, batteryfeature, phoneCallFeature, motionFeature]
        do {
            if let configuration = try Config(applicationId: "appId", applicationLocale: Locale.current, currentUser: user, currentMode: Mode.manual, currentTripRecorderFeatures: features) {
                tripRecorder = TripRecorder(configuration: configuration)
                tripRecorder!.start()
            }
        } catch ConfigurationError.LocationNotDetermined(let description) {
            print(description)
        } catch {
            print("\(error)")
        }
        
    }

}

