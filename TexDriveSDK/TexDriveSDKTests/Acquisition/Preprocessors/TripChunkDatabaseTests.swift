//
//  TripChunkDatabaseTests.swift
//  TexDriveSDKTests
//
//  Created by A944VQ on 18/01/2021.
//  Copyright © 2021 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK

class TripChunkDatabaseTests: XCTestCase {
    var tripChunkDatabase = TripChunkDatabase(path: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!, name: "TripChunkDatabaseTests.dbs")
    
    override func setUpWithError() throws {
        tripChunkDatabase = TripChunkDatabase(path: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!, name: "TripChunkDatabaseTests.dbs")
            XCTAssertNotNil(tripChunkDatabase)
    }

    override func tearDownWithError() throws {
        tripChunkDatabase?.close()
    }
    
    func testInit() throws {
        let name = #function+".dbs"
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let path = paths.first!
        let tripChunkDatabase = TripChunkDatabase(path: path, name: name)
        XCTAssertNotNil(tripChunkDatabase)
    }
    
    
    func testCreateTripChunkTable() throws {
        XCTAssertTrue(tripChunkDatabase!.createTripChunkTable())
    }

    func testInsertTripChunk() throws {
        let tripChunk = TripChunk(tripInfos: TripInfos(appId: "TOTO", user: TexUser.Anonymous, domain: Platform.Preproduction, isAPIV2: false))
        let countTripChunksBeforeInsert = tripChunkDatabase!.showTripChunks().count
        print("countTripChunksBeforeInsert \(countTripChunksBeforeInsert) \(tripChunkDatabase!.showTripChunks())")
        tripChunkDatabase!.insert(tripchunk: tripChunk)
        let countTripChunksAfterInsert = tripChunkDatabase!.showTripChunks().count
        print("countTripChunksAfterInsert \(countTripChunksBeforeInsert) \(tripChunkDatabase!.showTripChunks())")
        XCTAssertTrue( (countTripChunksBeforeInsert + 1) == countTripChunksAfterInsert)
    }
    
    func testPopTripChunk() throws {
        let tripChunk = TripChunk(tripInfos: TripInfos(appId: "TOTO", user: TexUser.Anonymous, domain: Platform.Preproduction, isAPIV2: false))
        let jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: tripChunk.serialize(), options:[])
        } catch let error {
            XCTAssertNil(error)
            return
        }
        let tripchunkData = jsonData!
        let payloadToDecode = String(bytes:tripchunkData, encoding: String.Encoding.utf8)
        XCTAssertNotNil(payloadToDecode)
        
        tripChunkDatabase!.insert(tripchunk: tripChunk)
        
        let (payload, baseurl) = tripChunkDatabase!.pop() ?? ("SCD", "SCDVGBH")
        XCTAssertEqual(payload, payloadToDecode)
        XCTAssertEqual(baseurl, tripChunk.tripInfos.baseUrl())
    }
}
