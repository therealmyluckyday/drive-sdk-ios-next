//
//  Fix.swift
//  TexDriveSDK
//
//  Created by Axa on 11/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

class Fix : CustomStringConvertible {
    var description: String
    
    let timestamp: Date
    init(date: Date) {
        timestamp = date
        description = "FIX \(timestamp)"
    }
}
