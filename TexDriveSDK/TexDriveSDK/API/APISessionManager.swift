//
//  APISessionManager.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 30/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

struct APIError: Error {
    var message: String
    var statusCode: Int
    lazy var localizedDescription: String =  {
        "Error on request \(self.statusCode) message: \(self.message)"
    }()
    
    init(message: String, statusCode: Int) {
        self.message = message
        self.statusCode = statusCode
    }
}

public protocol APISessionManagerProtocol {
    func put(dictionaryBody: [String: Any])
    func get(parameters: [String: Any], completionHandler: @escaping (Result<[String: Any]>) -> ())
}


class APISessionManager: NSObject, APISessionManagerProtocol, URLSessionDelegate, URLSessionDownloadDelegate, URLSessionTaskDelegate {
    // MARK: Property
    private let configuration : APIConfiguration
    private lazy var urlBackgroundTaskSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "TexSession")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        config.httpAdditionalHeaders = self.configuration.httpHeaders()
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    private lazy var urlDataTaskSession: URLSession = {
        let config = URLSessionConfiguration.default
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
    
    // MARK: PUT HTTP
    func put(dictionaryBody: [String: Any]) {
        if let url = URL(string: "\(self.configuration.baseUrl())/data") {
            let dictionaryBody = Dictionary<String, Any>.serializeWithGeneralInformation(dictionary: dictionaryBody, appId: self.configuration.appId, user: self.configuration.user)
            if let request = URLRequest.createUrlRequest(url: url, body: dictionaryBody, httpMethod: HttpMethod.PUT) {
                let backgroundTask = self.urlBackgroundTaskSession.downloadTask(with: request)
//                backgroundTask.earliestBeginDate = Date().addingTimeInterval(250)
                backgroundTask.resume()
            }
        }
    }
    
    
    // MARK: GET HTTP
    func get(parameters: [String: Any], completionHandler: @escaping (Result<[String: Any]>) -> ()) {
        if let url = URL(string: "\(self.configuration.baseUrl())/score") {
            Log.print(url.absoluteString)

            var urlComponent = URLComponents(string: "\(self.configuration.baseUrl())/score")
            var queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
            
            urlComponent?.queryItems = queryItems
            
            if let url = urlComponent?.url {
                let request = URLRequest(url: url)
                let task = self.urlDataTaskSession.dataTask(with: request) { (data, response, error) in
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            var statusCode = 400
                            if let httpResponse = response as? HTTPURLResponse {
                                statusCode = httpResponse.statusCode
                            }
                            var message = "Unkown error on API"
                            if let data = data,
                                let string = String(data: data, encoding: .utf8) {
                                message = string
                                Log.print(string, type: LogType.Error)
                            }
                            
                            if let error = error {
                                Log.print("Error On API \(error)", type: LogType.Error)
                                print(error)
                                completionHandler(Result.Failure(error))
                            }
                            else {
                                Log.print("Error On API", type: LogType.Error)
                                let apiError = APIError(message: message, statusCode: statusCode)
                                completionHandler(Result.Failure(apiError))
                            }
                            return
                    }
                    do {
                        if let data = data {
                            if let json = try (JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)) as? [String: Any] {
                                completionHandler(Result.Success(json))
                            }
                            else {
                                completionHandler(Result.Success([String: Any]()))
                            }
                        }
                        
                    } catch let jsonError {
                        if let data = data,
                            let string = String(data: data, encoding: .utf8) {
                            Log.print(string, type: LogType.Info)
                        }
                        Log.print("Error On API JSON", type: LogType.Error)
                        completionHandler(Result.Failure(jsonError))
                    }
                }
                task.resume()
            }
        }
    }
    
    // MARK: URLSessionDelegate Method
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegateTex,
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
            Log.print(location.absoluteString)
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
    
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        Log.print("HTTP urlsession")
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        Log.print("HTTP urlsession")
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        Log.print("HTTP urlsession")
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        Log.print("HTTP urlsession")
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        Log.print("HTTP urlsession")
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        Log.print("HTTP urlsession")
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Swift.Void) {
        Log.print("HTTP urlsession")
    }
}


