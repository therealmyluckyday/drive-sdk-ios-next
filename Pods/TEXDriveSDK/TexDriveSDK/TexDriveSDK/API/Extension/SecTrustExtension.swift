//
//  SecTrustExtension.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 29/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

protocol SecurityPolicy {
    func isServerTrustValid() -> Bool
    func certificateTrustChainData() -> [Data]
    func isRemoteCertificateMatchingPinnedCertificate(domain: String) -> Bool
}

extension SecTrust: SecurityPolicy {
    func isServerTrustValid() -> Bool {
        let result = UnsafeMutablePointer<SecTrustResultType>.allocate(capacity: 1)
        SecTrustEvaluate(self, result)
        return (result.pointee == SecTrustResultType.unspecified) || (SecTrustResultType.proceed == result.pointee)
    }
    
    
    func certificateTrustChainData() -> [Data] {
        var trustChains = [Data]()
        let count = SecTrustGetCertificateCount(self)
        var i = 0
        while i < count {
            if let certificate = SecTrustGetCertificateAtIndex(self, i) {
                trustChains.append(SecCertificateCopyData(certificate) as Data)
            }
            i += 1
        }
        return trustChains
    }
    
    func isRemoteCertificateMatchingPinnedCertificate(domain: String) -> Bool {
        let myCertName = "TEX-elb-ssl"
        if let myCertPath = Bundle(for: APITrip.self).path(forResource: myCertName, ofType: "der") {
            if let pinnedCertData = NSData(contentsOfFile: myCertPath) {
                let policy = SecPolicyCreateSSL(true, domain as CFString)
                let policies = [policy]
                SecTrustSetPolicies(self, policies as CFArray)
                
                let pinnedCertificates = [SecCertificateCreateWithData(nil, pinnedCertData)]
                SecTrustSetAnchorCertificates(self, pinnedCertificates as CFArray)
                if !self.isServerTrustValid() {
                    return false
                }
                
                // Compare certificate data
                // obtain the chain after being validated, which *should* contain the pinned certificate in the last position (if it's the Root CA)
                let serverCertificates = self.certificateTrustChainData()
                for certificateData in serverCertificates.reversed() {
                    if pinnedCertData.isEqual(to: certificateData) {
                        Log.print("Certificate data matches")
                        return true
                    }
                    else {
                        Log.print("Mismatch IN CERT DATA", type: .Error)
                    }
                }
            } else {
                Log.print("Couldn't read pinning certificate data", type: .Error)
            }
        } else {
            Log.print("Couldn't load pinning certificate!", type: .Error)
        }
        return false
    }
}
