//
//  APIScoreSessionManager.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 14/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import UIKit

public protocol APIScoreSessionManagerProtocol {
    func get(parameters: [String: Any], completionHandler: @escaping (Result<[String: Any]>) -> ())
}

class APIScoreSessionManager: APISessionManager, APIScoreSessionManagerProtocol {
    // MARK: Property
    private lazy var urlDataTaskSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = self.configuration.httpHeaders()
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    // MARK: GET HTTP
    func get(parameters: [String: Any], completionHandler: @escaping (Result<[String: Any]>) -> ()) {
        if let url = URL(string: "\(configuration.baseUrl())/score") {
            var urlComponent = URLComponents(string: "\(configuration.baseUrl())/score")
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
                            if let error = error {
                                Log.print("Error On API \(error)", type: LogType.Error)
                                completionHandler(Result.Failure(error))
                            }
                            else {
                                if let httpResponse = response as? HTTPURLResponse {
                                    let apiError = APISessionManager.manageError(data: data, httpResponse: httpResponse)
                                    completionHandler(Result.Failure(apiError))
                                }
                                else {
                                    let apiError = APIError(message: "Unknown API Error", statusCode: 400)
                                    completionHandler(Result.Failure(apiError))
                                }
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
}
