//
//  DatabaseManager.swift
//  minty
//
//  Created by Jacob Beene on 3/23/24.
//

import Foundation
import SQLite

class DatabaseManager {
    static let instance = DatabaseManager()  // Singleton instance
    private let db: Connection?

    init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        db = try? Connection("\(path)/db.sqlite3")
    }
    
    func initializeTables() {
        do {
            try TransactionManager.instance.createTable()
            try CategoryManager.instance.createTable()
        } catch {
            print("Error initializing tables: \(error)")
        }
    }
    
    func getDBConnection() -> Connection? {
        return db
    }
    
    func clearDatabase() {
        let allTables = ["categories", "transactions"] // Add all your table names here
        do {
            for tableName in allTables {
                try db?.run("DROP TABLE IF EXISTS \(tableName)")
            }
        } catch {
            print("Error dropping tables: \(error)")
        }

    }
    
    enum DatabaseError: Error {
        case connectionError
        case idError
    }
}
