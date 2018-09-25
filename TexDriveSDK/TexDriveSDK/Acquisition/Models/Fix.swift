//
//  Fix.swift
//  TexDriveSDK
//
//  Created by Axa on 11/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

class Fix {
    
    var fixId: String
    var timestamp: Date
    
    init (fixId: String, timestamp: Date) {
        self.fixId = fixId
        self.timestamp = timestamp
    }
}
