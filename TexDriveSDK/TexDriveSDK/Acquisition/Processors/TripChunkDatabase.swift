//
//  TripChunkDatabase.swift
//  TexDriveSDK
//
//  Created by A944VQ on 18/01/2021.
//  Copyright © 2021 Axa. All rights reserved.
//

import Foundation
import SQLite3

enum SQLLiteType: Int {
    case Int    = 1
    case Float  = 2
    case Blobl  = 4
    case Text   = 3
    case Null   = 5
}

struct TripChunkDatabase {
    let database: OpaquePointer
    static let saveKey = "8cc18c9e582e753f"
    
    init?(path: String, name: String) {
        if let dbPointer = TripChunkDatabase.openDatabase(path: path, name: name){
            database = dbPointer
            if createTripChunkTable() {
                
            } else {
                return nil
            }
        } else {
            Log.print("Error not able to init database", type: LogType.Error)
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
                Log.print("Error \(result) for secure database", type: LogType.Error)
            }
        default:
            Log.print("Error \(resultSQLOpening) for opened connection to database at \(dbpath)", type: LogType.Error)
        }
        
        print("Unable to open database.")
        return nil
    }
    
    func createTripChunkTable() -> Bool {
        let result = sqlite3_exec(database, "create table if not exists tripchunk (id integer primary key autoincrement, payload text, baseurl text)", nil, nil, nil)
        if result != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(database)!)
            Log.print("Error \(result) creating table: \(errmsg) ", type: LogType.Error)
        }
        return result == SQLITE_OK
    }
    
    func insert(tripchunk: TripChunk) {
        let jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: tripchunk.serialize(), options:[])
        } catch let error {
            print(error)
            Log.print("Error \(error) for insert in database", type: LogType.Error)
            return
        }
        guard let tripchunkData = jsonData, let payloadToDecode = String(bytes:tripchunkData, encoding: String.Encoding.utf8) else {
            return
        }
        
        let payload = payloadToDecode as NSString
        let baseUrl: NSString = tripchunk.tripInfos.baseUrl() as NSString
        insert(payload: payload, baseUrl: baseUrl)
    }
    
    func insert(payload: NSString, baseUrl: NSString) {
        let insertStatementString = "INSERT INTO tripchunk (payload, baseurl) VALUES (?, ?);"
        var insertStatement: OpaquePointer?
        let resultPrepareStatement = sqlite3_prepare_v2(database, insertStatementString, -1, &insertStatement, nil)
        
        if resultPrepareStatement == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, payload.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, baseUrl.utf8String, -1, nil)
            
            let result = sqlite3_step(insertStatement)
            if result == SQLITE_DONE {
                print("\nSuccessfully inserted row.")
            } else {
                Log.print("Error \(result): Could not insert row.", type: LogType.Error)
            }
        } else {
            Log.print("Error \(resultPrepareStatement): insertstatement is not prepared.", type: LogType.Error)
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func showTripChunks() -> [Int] {
        print("\n showTripChunks")
        var tripchunksId = [Int]()
        let queryStatementString = "SELECT * FROM tripchunk;"
        var queryStatement: OpaquePointer?
        let prepareQueryStatement = sqlite3_prepare_v2(
            database,
            queryStatementString,
            -1,
            &queryStatement,
            nil
        )
        if prepareQueryStatement == SQLITE_OK {
            print("\n showTripChunks")
            var queryResultStatement = sqlite3_step(queryStatement)
            while (queryResultStatement == SQLITE_ROW) {
                let id = sqlite3_column_int(queryStatement, 0)
                print("\(id)")
                tripchunksId.append(Int(id))
                
                if let queryResultCol1 = sqlite3_column_text(queryStatement, 1),
                   let queryResultCol2 = sqlite3_column_text(queryStatement, 2){
                    let payload = String(cString: queryResultCol1)
                    let baseurl = String(cString: queryResultCol2)
                print("Query Result:")
                print("\(id) | \(payload) | \(baseurl)")
                }else {
                    Log.print("Error \(queryResultStatement)", type: LogType.Error)
                }
                queryResultStatement = sqlite3_step(queryStatement)
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(database))
            Log.print("Error \(prepareQueryStatement)", type: LogType.Error)
        }
        sqlite3_finalize(queryStatement)
        return tripchunksId
    }
    
    func close() {
        let result = sqlite3_close(database)
        if result != SQLITE_OK {
            Log.print("Error \(result) for closing database", type: LogType.Error)
        } else {
            print("SQLite exec OK")
        }
    }
    
    func pop() -> (String, String)? {
        let queryStatementString = "SELECT * FROM tripchunk ORDER BY id DESC;"
        var queryStatement: OpaquePointer?
        if sqlite3_prepare_v2(
            database,
            queryStatementString,
            -1,
            &queryStatement,
            nil
        ) == SQLITE_OK {
            let queryStatementStep = sqlite3_step(queryStatement)
            if ( queryStatementStep == SQLITE_ROW) {
                let id = sqlite3_column_int(queryStatement, 0)
                if let queryResultCol1 = sqlite3_column_text(queryStatement, 1),
                   let queryResultCol2 = sqlite3_column_text(queryStatement, 2){
                    let payload = String(cString: queryResultCol1)
                    let baseurl = String(cString: queryResultCol2)
                    print("Query Result:")
                    print("id \(id) | payload \(payload) | baseurl \(baseurl)")
                    
                    sqlite3_finalize(queryStatement)
                    //let queryDeleteStatementString = "DELETE * FROM tripchunk WHERE id = 2;"
                    let queryDeleteStatementString = "DELETE FROM tripchunk;"
                    
                    var queryDeleteStatement: OpaquePointer?
                    var queryDeletePrepareStatement = sqlite3_prepare_v2(
                        database,
                        queryDeleteStatementString,
                        -1,
                        &queryDeleteStatement,
                        nil
                    )
                    if queryDeletePrepareStatement == SQLITE_OK {
                        let queryDeleteStatementStep = sqlite3_step(queryDeleteStatement)
                        
                        if queryDeleteStatementStep == SQLITE_DONE {
                            print("\nSuccessfully deleted row.")
                        } else {
                            Log.print("Error \(queryDeleteStatementStep): Could not deleted row.", type: LogType.Error)
                        }
                        
                        } else {
                        let errorMessage = String(cString: sqlite3_errmsg(database))
                        Log.print("Error \(queryDeletePrepareStatement) : \(errorMessage)", type: LogType.Error)
                    }
                    sqlite3_finalize(queryDeleteStatement)
                    
                    return (payload, baseurl)
                }else {
                    Log.print("Error \(queryStatementStep)", type: LogType.Error)
                }
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(database))
            Log.print("Error \(errorMessage)", type: LogType.Error)
        }
        sqlite3_finalize(queryStatement)
        return nil
    }
}


struct QueryStatement {
    let database: OpaquePointer
    let query: String
    var queryStatement: OpaquePointer?
    var resultPrepare: Int32?
    var resultNextStep: Int32?
    
    mutating func prepare() -> Bool {
        resultPrepare = sqlite3_prepare_v2(
            database,
            query,
            -1,
            &queryStatement,
            nil
        )
        
        return resultPrepare == SQLITE_OK
    }
    
    func isPrepareQueryValid() -> Bool {
        return resultPrepare != nil && resultPrepare == SQLITE_OK
    }
    
    func getErrorMessage() -> String {
        return String(cString: sqlite3_errmsg(database))
    }
    
    mutating func nextStep() -> Bool {
        guard let queryStatement = queryStatement else {
            return false
        }
        resultNextStep = sqlite3_step(queryStatement)
        return resultNextStep == SQLITE_ROW
    }
    
    func finalize() {
        guard let queryStatement = queryStatement else {
            return
        }
        sqlite3_finalize(queryStatement)
    }
}

