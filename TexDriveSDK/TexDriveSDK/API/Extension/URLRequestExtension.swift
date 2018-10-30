//
//  URLRequestExtension.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 29/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import Compression

protocol TexURLRequest {
    static func createUrlRequest(url: URL, body: [String: Any]) -> URLRequest
}

extension URLRequest: TexURLRequest {
    static func createUrlRequest(url: URL, body: [String: Any]) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HttpMethod.PUT.rawValue
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options:[])
            //            print("-------------JSON-----------------------")
            //            print("\(String(describing: String(bytes:jsonData, encoding: String.Encoding.utf8)))")
            var compressedJsonData = Data(capacity:jsonData.count)
            let algorithm = COMPRESSION_ZLIB
            var compressedSize = 0
            jsonData.withUnsafeBytes { (sourceBufferUnsafeBytes: UnsafePointer<UInt8>) -> Void in
                compressedJsonData.withUnsafeMutableBytes({ (compressedBufferMutableUnsafeBytes: UnsafeMutablePointer<UInt8>) -> Void in
                    compressedSize = compression_encode_buffer(compressedBufferMutableUnsafeBytes, jsonData.count, sourceBufferUnsafeBytes, jsonData.count, nil, algorithm)
                })
            }
            if compressedSize > 0 {
                urlRequest.httpBody = jsonData
            }
        } catch {
            print("JSON ERROR")
        }
        
        return urlRequest
    }
}
