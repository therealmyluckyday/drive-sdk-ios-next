//
//  DateFormatterExtension.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 29/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

protocol SerializeFormattedTimeZone {
    static func formattedTimeZone () -> String
}

extension DateFormatter: SerializeFormattedTimeZone {
    static func formattedTimeZone () -> String {
        let localTimeZoneFormatter = DateFormatter()
        localTimeZoneFormatter.timeZone = TimeZone.current
        localTimeZoneFormatter.dateFormat = "Z"
        return localTimeZoneFormatter.string(from: Date())
    }
}
