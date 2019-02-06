//
//  UIDeviceExtension.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 29/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

protocol HardwareDetail {
    func hardwareString() -> String
    func os() -> String
}

extension UIDevice: HardwareDetail {
    func hardwareString() -> String {
        var name: [Int32] = [CTL_HW, HW_MACHINE]
        var size: Int = 2
        sysctl(&name, 2, nil, &size, nil, 0)
        var hw_machine = [CChar](repeating: 0, count: Int(size))
        sysctl(&name, 2, &hw_machine, &size, nil, 0)
        let hardware: String = String(cString: hw_machine)
        return hardware
    }
    
    func os() -> String {
        return "\(self.systemName) \(self.systemVersion)"
    }
}
