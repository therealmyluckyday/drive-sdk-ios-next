//
//  AutoModeLocationSensor.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 05/04/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import CoreLocation
import OSLog

public class AutoModeLocationSensor: LocationSensor {
    var slcLocationManager = CLLocationManager()
    var needToRefreshLocationManager: Bool = true
}
