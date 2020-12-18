//
//  StopRequestOperation.swift
//  TexDriveSDK
//
//  Created by A944VQ on 14/12/2020.
//  Copyright © 2020 Axa. All rights reserved.
//

import Foundation


@available(iOS 13.0, *)
class StopRequestOperation: Operation {
    /*
     
 */
    override func main() {
        //4
        if isCancelled {
          return
        }
        
        let userDefaultsTexSDK = UserDefaults(suiteName: BGAppTaskRequestIdentifier)
        //userDefaultsTexSDK?.setValue(lastTripChunk.serialize(), forKey: "dictionaryBody")
        //userDefaultsTexSDK?.setValue(lastTripChunk.tripInfos.baseUrl(), forKey: "baseUrl")
        
    }
 }
