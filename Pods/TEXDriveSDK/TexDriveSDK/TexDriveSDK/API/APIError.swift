//
//  APIError.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 04/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

struct APIError: Error {
    var message: String
    var statusCode: Int
    lazy var localizedDescription: String =  {
        "Error on request \(self.statusCode) message: \(self.message)"
    }()
    
    init(message: String, statusCode: Int) {
        self.message = message
        self.statusCode = statusCode
    }
}
