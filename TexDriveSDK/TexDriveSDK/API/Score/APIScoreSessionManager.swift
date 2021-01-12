//
//  APIScoreSessionManager.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 14/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import UIKit
import OSLog

public protocol APIScoreSessionManagerProtocol {
    func get(parameters: [String: Any], isAPIV2: Bool, completionHandler: @escaping (Result<[String: Any]> ) -> ())
}

class APIScoreSessionManager: APISessionManager, APIScoreSessionManagerProtocol {
    // MARK: GET HTTP
    func get(parameters: [String: Any], isAPIV2: Bool = false, completionHandler: @escaping (Result<[String: Any]>) -> ()) {
        
        var urlComponent = isAPIV2 ?  URLComponents(string: "\(configuration.baseUrl())/score/\(parameters["trip_id"] as! String)"):  URLComponents(string: "\(configuration.baseUrl())/score")
        
        Log.print("APIScoreSessionManager getScore \(urlComponent)")
        if (!isAPIV2) {
            var queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
            urlComponent?.queryItems = queryItems
        }
        
        if let url = urlComponent?.url {
            let request = URLRequest(url: url)
            let task = generateTask(request: request, completionHandler: completionHandler)
            task?.resume()
        }
    }
    
    func generateTask(request: URLRequest, completionHandler: @escaping (Result<[String: Any]>) -> ()) -> URLSessionDataTask? {
        let task = self.urlSession?.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    if let error = error {
                        Log.print("Error On API \(error)", type: LogType.Error)
                        completionHandler(Result.Failure(error))
                    }
                    else {
                        if let httpResponse = response as? HTTPURLResponse {
                            let apiError = APISessionManager.manageError(data: data, httpResponse: httpResponse)
                            Log.print("API Error: \(apiError)", type: LogType.Error)
                            self.retry(request: request, completionHandler: completionHandler)
                        }
                        else {
                            let apiError = APIError(message: "Unknown API Error", statusCode: 400)
                            Log.print("Unknown API Error: \(apiError)", type: LogType.Error)
                            completionHandler(Result.Failure(apiError))
                        }
                    }
                    return
            }
            do {
                if let data = data {
                    if let json = try (JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)) as? [String: Any] {
                        let status = json["status"] as! String
                        if (status == "not_found") {
                            self.retry(request: request, completionHandler: completionHandler)
                        } else {
                            completionHandler(Result.Success(json))
                        }
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
        return task
    }
    
    func retry(request: URLRequest, completionHandler: @escaping (Result<[String: Any]>) -> ()) {
        Log.print("Retry")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(60)) {
            let task = self.generateTask(request: request, completionHandler: completionHandler)
            Log.print("Retry")
            task?.resume()
        }
    }
}

