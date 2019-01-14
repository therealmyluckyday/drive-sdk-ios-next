//
//  APITripSessionManager.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 14/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import UIKit
import RxSwift

public protocol APITripSessionManagerProtocol {
    func put(dictionaryBody: [String: Any])
}
class APITripSessionManager: APISessionManager, APITripSessionManagerProtocol, URLSessionDownloadDelegate, URLSessionTaskDelegate {
    // MARK: Property
    private lazy var urlBackgroundTaskSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "TexSession")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        config.timeoutIntervalForResource = 15 * 60 * 60
        config.httpAdditionalHeaders = self.configuration.httpHeaders()
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    
    let tripIdFinished = PublishSubject<TripId>()
    
    //Recreate the Session If the App Was Terminated
    /*
     If the system terminated the app while it was suspended, the system relaunches the app in the background. As part of your launch time setup, recreate the background session (see Listing 1), using the same session identifier as before, to allow the system to reassociate the background download task with your session. You do this so your background session is ready to go whether the app was launched by the user or by the system. Once the app relaunches, the series of events is the same as if the app had been suspended and resumed, as discussed earlier in
     */
    

    
    // MARK: PUT HTTP
    func put(dictionaryBody: [String: Any]) {
        if let url = URL(string: "\(configuration.baseUrl())/data") {
            if let request = URLRequest.createUrlRequest(url: url, body: dictionaryBody, httpMethod: HttpMethod.PUT) {
                let backgroundTask = self.urlBackgroundTaskSession.downloadTask(with: request)
                backgroundTask.resume()
            }
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
                if let tripId = APITripSessionManager.getTripId(task: downloadTask), APITripSessionManager.isTripStoppedSend(task:downloadTask) {
                    tripIdFinished.onNext(tripId)
                }
            } else {
                Log.print("HTTP Error \(httpResponse.statusCode)", type: .Error)
            }
            let data = try Data(contentsOf: savedURL)
            if let body = String(bytes: data, encoding: String.Encoding.utf8) {
                Log.print("HTTP Body \(body)")
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
    
    // MARK : func isTripStopedSend(on: downloadTask) -> Bool
    class func isTripStoppedSend(task: URLSessionDownloadTask) -> Bool {
        if let body = task.currentRequest?.httpBody {
            do {
                if let json = try (JSONSerialization.jsonObject(with: body, options: JSONSerialization.ReadingOptions.allowFragments)) as? [String: Any] {
                    if let fixes = json["fixes"] as? [[String: Any]] {
                        for fix in fixes {
                            if let events = fix["event"] as? [String], events.contains(EventType.stop.rawValue) {
                                return true
                            }
                        }
                    }
                }
            } catch {
                return false
            }
        }
        return false
    }
    
    class func getTripId(task: URLSessionDownloadTask) -> TripId? {
        if let body = task.currentRequest?.httpBody {
            do {
                if let json = try (JSONSerialization.jsonObject(with: body, options: JSONSerialization.ReadingOptions.allowFragments)) as? [String: Any] {
                    if let tripIdString = json["trip_id"] as? String, let tripId = TripId(uuidString: tripIdString) {
                        return tripId
                    }
                }
            } catch {
                return nil
            }
        }
        return nil
        
    }
}

