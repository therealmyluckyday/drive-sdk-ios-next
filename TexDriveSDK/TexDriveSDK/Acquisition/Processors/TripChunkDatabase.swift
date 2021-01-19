//
//  TripChunkDatabase.swift
//  TexDriveSDK
//
//  Created by A944VQ on 18/01/2021.
//  Copyright © 2021 Axa. All rights reserved.
//

import Foundation
import SQLite3

struct TripChunkDatabase {
    let database: OpaquePointer
    static let saveKey = "8cc18c9e582e753f"
    
    init?(path: String, name: String) {
        //let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        //let documentDirectory = paths.first!
        //let databaseName = "texTripChunkTEST.dbs"
        if let dbPointer = TripChunkDatabase.openDatabase(path: path, name: name) {
            database = dbPointer
        } else {    
            return nil
        }
    }
    
    static func openDatabase(path: String, name: String) -> OpaquePointer? {
        let dbpath = (path as NSString).appendingPathComponent(name)
        var db: OpaquePointer?
        let resultSQLOpening = sqlite3_open(dbpath, &db)
        switch resultSQLOpening {
        case SQLITE_OK:
            print("Successfully opened connection to database at \(dbpath)")
            let activate_see_key = "PRAGMA key='\(saveKey)';"
            let result = sqlite3_exec(db, activate_see_key, nil, nil, nil)
            switch result {
            case SQLITE_OK:
                print("Successfully secure connection to database)")
                return db
            default:
                print("Error \(result) for secure database")
            }
        default:
            print("Error \(resultSQLOpening) for opened connection to database at \(dbpath)")
        }
        
        print("Unable to open database.")
        return nil
    }
    
    func createTripChunkTable() -> Bool {
        let result = sqlite3_exec(database, "create table if not exists tripchunk (id integer primary key autoincrement, payload text, baseurl text)", nil, nil, nil)
        if result != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(database)!)
            print("error creating table: \(errmsg) \(result) ")
        }
        return result == SQLITE_OK
    }
    
    func insert(tripchunk: TripChunk) {
        let jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: tripchunk.serialize(), options:[])
        } catch let error {
            print(error)
            return
        }
        guard let tripchunkData = jsonData, let payloadToDecode = String(bytes:tripchunkData, encoding: String.Encoding.utf8) else {
            return
        }
        
        Log.print("payloadToDecode \(payloadToDecode)")
        
        let insertStatementString = "INSERT INTO tripchunk (payload, baseurl) VALUES (?, ?);"
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(database, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            let payload = payloadToDecode as NSString
            let baseUrl: NSString = tripchunk.tripInfos.baseUrl() as NSString
            
            sqlite3_bind_text(insertStatement, 2, payload.utf8String, -1, nil)
            
            sqlite3_bind_text(insertStatement, 3, baseUrl.utf8String, -1, nil)
            
            let result = sqlite3_step(insertStatement)
            if result == SQLITE_DONE {
                print("\nSuccessfully inserted row.")
            } else {
                print("\nCould not insert row.")
            }
        } else {
            print("\nINSERT statement is not prepared.")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func showTripChunks() -> [Int] {
        var tripchunksId = [Int]()
        let queryStatementString = "SELECT * FROM tripchunk;"
        var queryStatement: OpaquePointer?
        if sqlite3_prepare_v2(
            database,
            queryStatementString,
            -1,
            &queryStatement,
            nil
        ) == SQLITE_OK {
            print("\n")
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let id = sqlite3_column_int(queryStatement, 0)
                print("\(id)")
                tripchunksId.append(Int(id))
                if let queryResultCol1 = sqlite3_column_text(queryStatement, 1) {
                let name = String(cString: queryResultCol1)
                print("Query Result:")
                print("\(id) | \(name)")
                }else {
                    print("Query result is nil.")
                    //sqlite3_finalize(queryStatement)
                    //return tripchunksId
                }
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(database))
            print("\nQuery is not prepared \(errorMessage)")
        }
        sqlite3_finalize(queryStatement)
        return tripchunksId
    }
    
    func close() {
        let result = sqlite3_close(database)
        if result != SQLITE_OK {
            print("error closing database \(result)")
        } else {
            print("SQLite exec OK")
        }
    }
    
    func pop() -> (String, String)? {
        let queryStatementString = "SELECT * FROM tripchunk;"
        var queryStatement: OpaquePointer?
        if sqlite3_prepare_v2(
            database,
            queryStatementString,
            -1,
            &queryStatement,
            nil
        ) == SQLITE_OK {
            print("\n")
            if (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let id = sqlite3_column_int(queryStatement, 0)
                print("\(id)")
                if let queryResultCol1 = sqlite3_column_text(queryStatement, 1) {
                    let name = String(cString: queryResultCol1)
                    print("Query Result:")
                    print("\(id) | \(name)")
                    print("CREATE TRIPCHUNK")
                }else {
                    print("Query result is nil.")
                    return nil
                }
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(database))
            print("\nQuery is not prepared \(errorMessage)")
        }
        sqlite3_finalize(queryStatement)
        return nil
    }
}
