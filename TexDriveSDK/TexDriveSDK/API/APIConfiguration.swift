//
//  APIConfiguration.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 30/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
enum HttpMethod: String {
    case PUT = "PUT"
}

enum Domain: String {
    case Integration = "gw-int.tex.dil.services"
    case Preproduction = "gw-preprod.tex.dil.services"
    case Production = "gw.tex.dil.services"
}

struct APIConfiguration {
    let appId: String
    let domain: Domain
    
    func baseUrl() -> String {
        return "https://"+domain.rawValue+"/v2.0"
    }
    
    func httpHeaders() -> [String: Any] {
        return ["Content-Encoding": "gzip", "X-AppKey": appId]
    }
}
