//
//  Fix.swift
//  TexDriveSDK
//
//  Created by Axa on 11/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

protocol Fix: CustomStringConvertible {
    var timestamp: TimeInterval { get } //location.timestamp.timeIntervalSince1970 * 1000
}
