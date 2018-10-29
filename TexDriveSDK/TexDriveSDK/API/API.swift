//
//  API.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 23/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift

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
        return ["gzip": "Content-Encoding", "X-AppKey": appId]
    }
}

class API: NSObject, URLSessionDelegate, URLSessionDownloadDelegate, URLSessionTaskDelegate {
    // MARK: Property
    private let configuration : APIConfiguration
    private let disposeBag = DisposeBag()
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "TexSession")
        //config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        config.httpAdditionalHeaders = self.configuration.httpHeaders()
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    // MARK: LifeCycle
    init(configuration: APIConfiguration) {
        self.configuration = configuration
    }
    //Recreate the Session If the App Was Terminated
    /*
     If the system terminated the app while it was suspended, the system relaunches the app in the background. As part of your launch time setup, recreate the background session (see Listing 1), using the same session identifier as before, to allow the system to reassociate the background download task with your session. You do this so your background session is ready to go whether the app was launched by the user or by the system. Once the app relaunches, the series of events is the same as if the app had been suspended and resumed, as discussed earlier in
 */
    
    // MARK: Public Method
    func subscribe(providerTrip: PublishSubject<Trip>) {
        providerTrip.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in
            if let trip = event.element {
                self?.sendTrip(trip: trip)
            }
        }.disposed(by: disposeBag)
    }
    
    func sendTrip(trip: Trip) {
        print("@@@@@@URL \(self.configuration.baseUrl())/data")
        if let url = URL(string: "\(self.configuration.baseUrl())/data") {
            let backgroundTask = self.urlSession.downloadTask(with: URLRequest.createUrlRequest(url: url, body: (self.serializeWithGeneralInformation(dictionary: trip.serialize())) ))
            print("backgroundTask \(backgroundTask)")
            backgroundTask.resume()
        }
    }
    
    func serializeWithGeneralInformation(dictionary: [String: Any]) -> [String: Any] {
        var newDictionary = dictionary
        let uuid = UIDevice.current.identifierForVendor?.uuidString
        let timeZone = DateFormatter.formattedTimeZone()
        let os = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        let model = UIDevice.current.hardwareString()
        let sdkVersion = Bundle(for: type(of: self)).infoDictionary!["CFBundleShortVersionString"] as! String
        let firstVia = "TEX_iOS_SDK/\(os)/\(sdkVersion)"
        //        token _texConfig.texUser.authToken
        //        client_id _texConfig.texUser.userId
        newDictionary["uid"] = uuid
        newDictionary["timezone"] = timeZone
        newDictionary["os"] = os
        newDictionary["model"] = model
        newDictionary["version"] = sdkVersion
        newDictionary["app_name"] = self.configuration.appId
        newDictionary["via"] = [firstVia]
        return newDictionary
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
        print("\(String(describing: error))")
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print("url session URLAuthenticationChallenge \(challenge)")
//        print("*** received SESSION challenge...\(challenge)")
        let trust = challenge.protectionSpace.serverTrust!
        let credential = URLCredential(trust: trust)
        
        let remoteCertMatchesPinnedCert = trust.isRemoteCertificateMatchingPinnedCertificate(domain: self.configuration.domain.rawValue)
        if remoteCertMatchesPinnedCert {
//            print("*** TRUSTING CERTIFICATE")
            completionHandler(.useCredential, credential)
        } else {
            print("NOT TRUSTING CERTIFICATE")
            completionHandler(.rejectProtectionSpace, nil)
        }
        if challenge.previousFailureCount > 0 {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        }
        if let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
        } else {
            print("unknown state. error: \(String(describing: challenge.error))")
        }
    }
    
    // MARK: URLSessionDownloadDelegate
    //Retrieving the downloaded file
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
//        print("Did finish downloading: \(location.absoluteString)")
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
            print("\(httpResponse)")
            if (200...299).contains(httpResponse.statusCode) {
//                print("success \(httpResponse.statusCode)")
            } else {
                print("error \(httpResponse.statusCode)")
            }
            let data = try Data(contentsOf: savedURL)
            if let body = String(bytes: data, encoding: String.Encoding.utf8) {
                print(body)
            }
        } catch {
            print ("file error: \(error)")
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else {
            return
        }
        let progress = Double(Double(totalBytesWritten)/Double(totalBytesExpectedToWrite))
        print("Download progress: \(progress)")
    }
    
    // MARK: URLSessionTaskDelegate Protocol
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if let error = error {
            print ("connection error: \(error)")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        print("urlsession WillperformHTTPRedirection")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("urlsession didSendBodyData \(totalBytesSent)")
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        print("urlsession needNewBodyStream \(task)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        print("urlsession delayedRequest \(task)")
        completionHandler(URLSession.DelayedRequestDisposition.continueLoading, nil)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        //print("urlsession didFinishCollecting \(task)")
    }
}
