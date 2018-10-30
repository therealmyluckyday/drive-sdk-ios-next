//
//  DoubleExtension.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 29/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

protocol RoundedDouble {
    func rounded(toDecimalPlaces n: Int) -> Decimal
}

extension Double: RoundedDouble {
    func rounded(toDecimalPlaces n: Int) -> Decimal {
        let result = self.roundedDecimal(to: 6, mode: .plain)
        return result
    }
    
    /// Convert `Double` to `Decimal`, rounding it to `scale` decimal places.
    ///
    /// - Parameters:
    ///   - scale: How many decimal places to round to. Defaults to `0`.
    ///   - mode:  The preferred rounding mode. Defaults to `.plain`.
    /// - Returns: The rounded `Decimal` value.
    func roundedDecimal(to scale: Int = 0, mode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var decimalValue = Decimal(self)
        var result = Decimal()
        NSDecimalRound(&result, &decimalValue, scale, mode)
        return result
    }
}
