//
//  APITripSessionManager.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 14/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import UIKit
import RxSwift
import Gzip

public protocol APITripSessionManagerProtocol {
    func put(dictionaryBody: [String: Any], baseUrl: String)
    func put(body: String, baseUrl: String)
    var tripChunkSent: PublishSubject<Result<TripId>> { get }
    var tripIdFinished: PublishSubject<TripId> { get }
}

class APITripSessionManager: APISessionManager, APITripSessionManagerProtocol, URLSessionDownloadDelegate {
    // MARK: Property
    
    let tripIdFinished = PublishSubject<TripId>()
    let tripChunkSent = PublishSubject<Result<TripId>>()
    var retryCount = 0
    
    //Recreate the Session If the App Was Terminated
    /*
     If the system terminated the app while it was suspended, the system relaunches the app in the background. As part of your launch time setup, recreate the background session (see Listing 1), using the same session identifier as before, to allow the system to reassociate the background download task with your session. You do this so your background session is ready to go whether the app was launched by the user or by the system. Once the app relaunches, the series of events is the same as if the app had been suspended and resumed, as discussed earlier in
     */
    
    
    // MARK: PUT HTTP
    func put(dictionaryBody: [String: Any], baseUrl: String) {
        if let url = URL(string: "\(baseUrl)/data"), let request = URLRequest.createUrlRequest(url: url, body: dictionaryBody, httpMethod: HttpMethod.PUT, withCompression: true) {
            Log.print("[\(url)]\n[\(String(describing: request.allHTTPHeaderFields))]\nHTTP dictionaryBody \(dictionaryBody)")
            let backgroundTask = self.urlSession?.downloadTask(with: request)
            backgroundTask?.resume()
        }
    }
    
    func put(body: String, baseUrl: String) {
        if let url = URL(string: "\(baseUrl)/data"), let request = URLRequest.createUrlRequest(url: url, body: body, httpMethod: HttpMethod.PUT, withCompression: true) {
            Log.print("[\(url)]\n[\(String(describing: request.allHTTPHeaderFields))]\nHTTP dictionaryBody \(body)")
            let backgroundTask = self.urlSession?.downloadTask(with: request)
            backgroundTask?.resume()
        }
    }
    
    // MARK: URLSessionDownloadDelegate
    // Retrieving the downloaded file
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let httpResponse = downloadTask.response as? HTTPURLResponse else {
            return
        }
        Log.print(location.absoluteString)
        Log.print("HTTP response \(httpResponse)")
        if (200...299).contains(httpResponse.statusCode), let tripId = APITripSessionManager.getTripId(task: downloadTask) {
            Log.print("TripId: \(tripId)")
            retryCount = 0
            Log.print("tripChunkSent.onNext(Result.Success(tripId)")
            tripChunkSent.onNext(Result.Success(tripId))
            if APITripSessionManager.isTripStoppedSend(task:downloadTask) {
                Log.print("Trip Finished")
                tripIdFinished.onNext(tripId)
            }
        } else {
            Log.print("HTTP Error \(httpResponse.statusCode)", type: .Error)
            do {
                let documentsURL = try
                    FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let savedURL = documentsURL.appendingPathComponent(
                    location.lastPathComponent)
                try FileManager.default.moveItem(at: location, to: savedURL)
                let data = try Data(contentsOf: savedURL)
                if let body = String(bytes: data, encoding: String.Encoding.utf8) {
                    Log.print("HTTP Body \(body)")
                }
                APITripSessionManager.showRequestInformation(task: downloadTask)
                let apiError = APISessionManager.manageError(data: data, httpResponse: httpResponse)
                switch apiError.statusCode {
                case 429:
                    retry(task:downloadTask)
                case let x where x >= 500:
                    retry(task:downloadTask)
                default:
                    tripChunkSent.onNext(Result.Failure(apiError))
                }
            } catch {
                Log.print("HTTP File Error \(error)", type: .Error)
                let apiError = APIError(message: "Unable to Parse API response File", statusCode: httpResponse.statusCode)
                switch apiError.statusCode {
                case 429:
                    retry(task:downloadTask)
                case let x where x >= 500:
                    retry(task:downloadTask)
                default:
                    tripChunkSent.onNext(Result.Failure(apiError))
                }
            }
        }
    }
    
    func retry(task: URLSessionDownloadTask, error: Error? = nil) {
        Log.print("Retry")
        retryCount = retryCount + 1
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(60*retryCount)) { [weak self] in
            if let error = error as NSError?, let resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
                let backgroundTask = self?.urlSession?.downloadTask(withResumeData: resumeData)
                Log.print("Retry")
                backgroundTask?.resume()

            } else {
                if let request = task.currentRequest {
                    let backgroundTask = self?.urlSession?.downloadTask(with: request)
                    Log.print("Retry")
                    backgroundTask?.resume()
                }
            }
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
        if let error = error as NSError? {
            Log.print("HTTP connection error: \(error)", type: .Error)
            if let downloadTask = task as? URLSessionDownloadTask {
               Log.print("HTTP connection error downloadtask: \(downloadTask)")
                if error.domain != "NSPOSIXErrorDomain"  {
                    self.retry(task: downloadTask, error: error)
                }
            }
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
    
    @available(iOS 11.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        Log.print("HTTP urlsession delayedRequest \(task)")
        completionHandler(URLSession.DelayedRequestDisposition.continueLoading, nil)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        //Log.print("HTTP urlsession didFinishCollecting \(task)")
    }
    
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        Log.print("HTTP urlsession taskIsWaitingForConnectivity")
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        Log.print("HTTP urlsession didReceive challenge")
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        Log.print("HTTP urlsession didReceive response")
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        Log.print("HTTP urlsession didBecome downloadTask")
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        Log.print("HTTP urlsession didBecome streamTask")
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        Log.print("HTTP urlsession didReceive data")
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Swift.Void) {
        Log.print("HTTP urlsession willCacheResponse proposedResponse")
    }
    
    // MARK: - func isTripStopedSend(on: downloadTask) -> Bool
    class func isTripStoppedSend(task: URLSessionDownloadTask) -> Bool {
        Log.print("isTripStoppedSend")
        if let body = task.currentRequest?.httpBody {
            do {
                let bodyUncompress = try body.gunzipped()
                if let json = try (JSONSerialization.jsonObject(with: bodyUncompress, options: JSONSerialization.ReadingOptions.allowFragments)) as? [String: Any] {
                    if let fixes = json["fixes"] as? [[String: Any]] {
                        for fix in fixes {
                            if let events = fix["event"] as? [String], events.contains(EventType.stop.rawValue) {
                                return true
                            }
                        }
                    }
                }
            } catch {
                Log.print("\(error)", type: .Error)
                return false
            }
        }
        return false
    }
    
    class func showRequestInformation(task: URLSessionDownloadTask) {
        if let body = task.currentRequest?.httpBody, let bodyString = String(bytes: body, encoding: String.Encoding.utf8) {
            Log.print(bodyString, type: .Error)
        }
    }
    
    class func getTripId(task: URLSessionDownloadTask) -> TripId? {
        if let body = task.currentRequest?.httpBody {
            do {
                var data = body
                if body.isGzipped  {
                    data = try body.gunzipped()
                }
                if let json = try (JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)) as? [String: Any] {
                    if let tripIdString = json["trip_id"] as? String, let tripId = TripId(uuidString: tripIdString) {
                        return tripId
                    }
                }
            } catch let error as GzipError {
                Log.print("GzipError \(error)", type: .Error)
                return nil
            } catch  {
                Log.print("Error \(error)", type: .Error)
                return nil
            }
        }
        return nil
    }
}

