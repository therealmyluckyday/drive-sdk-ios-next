//
//  TexUser.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 11/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

public enum TexUser: Equatable {
    case Anonymous
    case Authentified(String)
}
