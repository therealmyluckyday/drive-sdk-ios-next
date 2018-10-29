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
    @IBOutlet weak var TripSegmentedControl: UISegmentedControl!
    
    var tripRecorder : TripRecorder?
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        let user = User.Anonymous
        do {
            if let configuration = try Config(applicationId: "APP-TEST", applicationLocale: Locale.current, currentUser: user, currentMode: Mode.manual) {
                tripRecorder = TripRecorder(config: configuration)
                tripRecorder!.start()
            }
        } catch ConfigurationError.LocationNotDetermined(let description) {
            print(description)
        } catch {
            print("\(error)")
        }
    }

    @IBAction func tripSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            tripRecorder!.start()
            break
        default:
            tripRecorder!.stop()
        }
    }
}

