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

public enum Platform: Int {
    case Production = 0
    case Testing = 1
    case Preproduction = 2
    case Integration = 3
    
    func generateUrl(isAPIV2: Bool) -> String {
        if isAPIV2 {
            switch self {
            case .Integration:
                return PlatformAPIV2.Integration.rawValue
            case .Preproduction:
                return PlatformAPIV2.Preproduction.rawValue
            case .Production:
                return PlatformAPIV2.Production.rawValue
            case .Testing:
                return PlatformAPIV2.Testing.rawValue
            }
        } else {
            switch self {
            case .Integration:
                return PlatformAPIV1.Integration.rawValue
            case .Preproduction:
                return PlatformAPIV1.Preproduction.rawValue
            case .Production:
                return PlatformAPIV1.Production.rawValue
            case .Testing:
                return PlatformAPIV1.Testing.rawValue
            }
        }
    }
}

public enum PlatformAPIV1: String {
    case Integration = "gw-int.tex.dil.services"
    case Preproduction = "gw-preprod.tex.dil.services"
    case Production = "gw.tex.dil.services"
    case Testing = "gw-uat.tex.dil.services"
}

public enum PlatformAPIV2: String {
    case Integration = "mobile-sink.youdrive-uat.next.dil.services"
    case Preproduction = "mobile-sink.youdrive-pp.next.dil.services"
    case Production = "mobile-sink.youdrive.next.dil.services"
    case Testing = "mobile-sink.youdrive-dev.next.dil.services"
}

protocol APIConfiguration {
    var domain: Platform { get }
    var isAPIV2: Bool { get }
    func baseUrl() -> String
    func httpHeaders() -> [String: Any]
}

extension TripInfos: APIConfiguration {
    func baseUrl() -> String {
        return isAPIV2 ? baseUrlAPIV2() : baseUrlAPIV1()
    }
    
    func baseUrlAPIV1() -> String {
        return "https://"+domain.generateUrl(isAPIV2: false)+"/v2.0"
    }
    
    func baseUrlAPIV2() -> String {
        return "https://"+domain.generateUrl(isAPIV2: true)+"/mobile"
    }
    
    func httpHeaders() -> [String: Any] {
        return ["Content-Encoding": "gzip", "X-AppKey": appId]
    }
}
