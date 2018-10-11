//
//  ViewController.swift
//  TexDriveApp
//
//  Created by Axa on 11/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import UIKit
import TexDriveSDK

class ViewController: UIViewController {

    let tripRecorder = TripRecorder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripRecorder.start()
    }

}

