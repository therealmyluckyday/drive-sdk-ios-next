//
//  TexConfigBuilder.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 12/04/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import Foundation

//let builder = AXATexConfigBuilder(appId: appName, texUser: texUser) else {
//
//    VSLoggerManager.swiftLog(domaine: "tex", level: 0, format: "Cannot init AXATexConfigBuilder")
//    return
//}

public class TexConfigBuilder {
    var appId: String {
        get {
            return _config.tripInfos.appId
        }
    }
    var texUser: User {
        get {
            return _config.tripInfos.user
        }
    }
    var config: TexConfig {
        get {
            return _config
        }
    }
    
    var _config: TexConfig

    public init(appId: String, texUser: User) {
        _config = TexConfig(applicationId: appId, currentUser: texUser)
    }
    
    public func enableTripRecorder() throws {
        let locationfeature : TripRecorderFeature = TripRecorderFeature.Location(LocationManager())
        try TexConfig.activable(features: [locationfeature])
    
        for feature in _config.tripRecorderFeatures {
            switch feature {
            case .Location(_):
                return
            case .Battery(_):
                break
            case .PhoneCall(_):
                break
            case .Motion(_):
                break
            }
        }
        _config.tripRecorderFeatures.append(locationfeature)
    }
    
    public func select(platform: Domain) -> TexConfigBuilder {
        _config.select(domain: platform)
        return self
    }
    
    public func build() -> TexConfig {
//        return config.copy()
        return config
    }
}

//config = builder.build()
//- (AXATexConfig *)build {
//    if (_config.isAutoModeEnabled && _config.isAutoModeBTEnabled){
//        NSString *exceptionMessage = @"Both AutoMode and AutoModeBT are enabled. Choose only one of them";
//        AXALogError(exceptionMessage);
//        [NSException raise:@"InvalidConfigurationException" format:@"%@", exceptionMessage];
//        return nil;
//    }
//    switch (_config.platform) {
//    case AXAPlatformPreprod:
//        AXALogInfo(@"Selection of platform: PreProd");
//        break;
//    case AXAPlatformTesting:
//        AXALogInfo(@"Selection of platform: Testing");
//        break;
//    case AXAPlatformProduction:
//        AXALogInfo(@"Selection of platform: Production");
//        break;
//    }
//    return [_config copy];
//}
//




