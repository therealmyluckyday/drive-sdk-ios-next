//
//  APIError.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 04/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

public struct APIError: LocalizedError {
    var message: String
    public var statusCode: Int
    public var description: String {
        get {
            return "Error on request \(self.statusCode) message: \(self.message)"
        }
    }

    public var errorDescription: String? {
        get {
            return self.description
        }
    }
    
    init(message: String, statusCode: Int) {
        self.message = message
        self.statusCode = statusCode
    }
}
