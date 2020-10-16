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
    case GET = "GET"
    case POST = "POST"
}

public enum Platform: String {
    case Integration = "gw-int.tex.dil.services"
    case Preproduction = "gw-preprod.tex.dil.services"
    case Production = "gw.tex.dil.services"
    case Testing = "gw-uat.tex.dil.services"
    case APIV2Testing = "mobile-sink.youdrive-dev.next.dil.services"
}

protocol APIConfiguration {
    var domain: Platform { get }
    func baseUrl() -> String
    func httpHeaders() -> [String: Any]
}

extension TripInfos: APIConfiguration {
    func baseUrl() -> String {
        return "https://"+domain.rawValue+"/v2.0"
    }
    
    func httpHeaders() -> [String: Any] {
        return ["Content-Encoding": "gzip", "X-AppKey": appId]
    }
}
