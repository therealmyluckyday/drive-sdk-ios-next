//
//  URLRequestExtension.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 29/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import Compression
import Gzip

protocol APIURLRequest {
    static func createUrlRequest(url: URL, body: [String: Any], httpMethod: HttpMethod, withCompression: Bool) -> URLRequest?
}

extension URLRequest: APIURLRequest {
    static func createUrlRequest(url: URL, body: [String: Any], httpMethod: HttpMethod, withCompression: Bool = false) -> URLRequest? {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options:[])
            Log.print("[Json]\(String(describing: String(bytes:jsonData, encoding: String.Encoding.utf8)))")
            urlRequest.httpBody = jsonData
            if withCompression {
                do {
                    urlRequest.httpBody = try jsonData.gzipped(level: .bestCompression)
                    urlRequest.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
                    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    Log.print("Error in compression \(error)", type: .Error)
                }
            } else {
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            Log.print("Json serialization error: \(error)", type: .Error)
            return nil
        }
        
        return urlRequest
    }
}
