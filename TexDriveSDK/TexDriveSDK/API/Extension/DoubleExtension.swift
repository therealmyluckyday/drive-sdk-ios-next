//
//  DoubleExtension.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 29/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

protocol RoundedDouble {
    func rounded(toDecimalPlaces n: Int) -> Double
}

extension Double: RoundedDouble {
    func rounded(toDecimalPlaces n: Int) -> Double {
        return Double(String(format: "%.\(n)f", self))!
        //        let multiplier = pow(10, Double(n))
        //return (multiplier * self).rounded()/multiplier
        //        return Double(Int((multiplier * self)))/multiplier
    }
}
