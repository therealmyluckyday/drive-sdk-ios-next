//
//  APISessionManager.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 30/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

class APISessionManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    // MARK: Property
    internal let configuration: APIConfiguration
    internal var urlSession: URLSession?
    //Recreate the Session If the App Was Terminated
    /*
     If the system terminated the app while it was suspended, the system relaunches the app in the background. As part of your launch time setup, recreate the background session (see Listing 1), using the same session identifier as before, to allow the system to reassociate the background download task with your session. You do this so your background session is ready to go whether the app was launched by the user or by the system. Once the app relaunches, the series of events is the same as if the app had been suspended and resumed, as discussed earlier in
     */
    
    // MARK: APITEXTravel Protocol Method
    required init(configuration: APIConfiguration, urlSessionConfiguration: URLSessionConfiguration) {
        self.configuration = configuration
        super.init()
        self.urlSession = URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: nil)
    }
   
    // MARK: - URLSessionDelegate
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        Log.print("urlsession didBecomeInvalidWithError :\(String(describing: error))", type: .Error)
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let trust = challenge.protectionSpace.serverTrust else {  completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            return
        }
        let credential = URLCredential(trust: trust)
        
        if !configuration.isAPIV2 {
            let remoteCertMatchesPinnedCert = trust.isRemoteCertificateMatchingPinnedCertificate(domain: self.configuration.domain.generateUrl(isAPIV2: false))
            if remoteCertMatchesPinnedCert {
                completionHandler(.useCredential, credential)
            } else {
                Log.print("Error no trusting certificate", type: .Error)
                completionHandler(.rejectProtectionSpace, nil)
            }
        }
        if challenge.previousFailureCount > 0 {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        }
        if let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
        } else {
            Log.print("server trust error \(String(describing: challenge.error))", type: .Error)
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Log.print("urlsession urlSessionDidFinishEvents :\(String(describing: session))", type: .Info)
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as? AppDelegateTex
            guard let completionHandler = appDelegate?.backgroundCompletionHandler else { return  }
            appDelegate?.backgroundCompletionHandler = nil
            completionHandler()
        }
    }
    
    class func manageError(data: Data?, httpResponse: HTTPURLResponse) -> APIError {
        let statusCode = httpResponse.statusCode
        var message = "Unkown error on API"
        if let data = data,
            let string = String(data: data, encoding: .utf8) {
            message = string
            Log.print(string, type: LogType.Error)
        }
        Log.print("Error On API", type: LogType.Error)
        return APIError(message: message, statusCode: statusCode)
    }
}


