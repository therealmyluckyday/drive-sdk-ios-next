//
//  APISessionManager.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 30/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

class APISessionManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate, URLSessionTaskDelegate {
    // MARK: Property
    private let configuration : APIConfiguration
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "TexSession")
        //config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        config.httpAdditionalHeaders = self.configuration.httpHeaders()
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    //Recreate the Session If the App Was Terminated
    /*
     If the system terminated the app while it was suspended, the system relaunches the app in the background. As part of your launch time setup, recreate the background session (see Listing 1), using the same session identifier as before, to allow the system to reassociate the background download task with your session. You do this so your background session is ready to go whether the app was launched by the user or by the system. Once the app relaunches, the series of events is the same as if the app had been suspended and resumed, as discussed earlier in
     */
    
    // MARK: APITEXTravel Protocol Method
    required init(configuration: APIConfiguration) {
        self.configuration = configuration
    }
    
    func put(dictionaryBody: [String: Any]) {
        if let url = URL(string: "\(self.configuration.baseUrl())/data") {
            let dictionaryBody = Dictionary<String, Any>.serializeWithGeneralInformation(dictionary: dictionaryBody, appId: self.configuration.appId)
            if let request = URLRequest.createUrlRequest(url: url, body: dictionaryBody, httpMethod: HttpMethod.PUT) {
                let backgroundTask = self.urlSession.downloadTask(with: request)
                backgroundTask.resume()
            }
        }
    }
    
    // MARK: URLSessionDelegate Method
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegateText,
                let backgroundCompletionHandler =
                appDelegate.backgroundCompletionHandler else {
                    return
            }
            appDelegate.backgroundCompletionHandler = nil
            backgroundCompletionHandler()
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        Log.print("-------------JSON ERROR-----------------------\(String(describing: error))", type: .Error)
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let trust = challenge.protectionSpace.serverTrust!
        let credential = URLCredential(trust: trust)
        
        let remoteCertMatchesPinnedCert = trust.isRemoteCertificateMatchingPinnedCertificate(domain: self.configuration.domain.rawValue)
        if remoteCertMatchesPinnedCert {
            Log.print("HTTP TRUSTING CERTIFICATE")
            completionHandler(.useCredential, credential)
        } else {
            Log.print("NOT TRUSTING CERTIFICATE", type: .Error)
            completionHandler(.rejectProtectionSpace, nil)
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
    
    // MARK: URLSessionDownloadDelegate
    // Retrieving the downloaded file
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let httpResponse = downloadTask.response as? HTTPURLResponse else {
            return
        }
        do {
            let documentsURL = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
            let savedURL = documentsURL.appendingPathComponent(
                location.lastPathComponent)
            try FileManager.default.moveItem(at: location, to: savedURL)
            Log.print("HTTP response \(httpResponse)")
            if (200...299).contains(httpResponse.statusCode) {

            } else {
                Log.print("HTTP Error \(httpResponse.statusCode)", type: .Error)
            }
            let data = try Data(contentsOf: savedURL)
            if let body = String(bytes: data, encoding: String.Encoding.utf8) {
                Log.print("HTTP BODY \(body)")
            }
        } catch {
            Log.print("HTTP File Error \(error)", type: .Error)
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else {
            return
        }
        let progress = Double(Double(totalBytesWritten)/Double(totalBytesExpectedToWrite))
        Log.print("HTTP Download progress: \(progress)")
    }
    
    // MARK: URLSessionTaskDelegate Protocol
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if let error = error {
            Log.print("HTTP connection error: \(error)", type: .Error)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        Log.print("HTTP urlsession WillperformHTTPRedirection")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        Log.print("HTTP urlsession didSendBodyData \(totalBytesSent)")
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        Log.print("HTTP urlsession needNewBodyStream \(task)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        Log.print("HTTP urlsession delayedRequest \(task)")
        completionHandler(URLSession.DelayedRequestDisposition.continueLoading, nil)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        Log.print("HTTP urlsession didFinishCollecting \(task)")
    }
}
