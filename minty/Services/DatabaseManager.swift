//
//  DatabaseManager.swift
//  minty
//
//  Created by Jacob Beene on 3/23/24.
//

import SQLite

class DatabaseManager {
    static let instance = DatabaseManager()
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
    
    func createIndexes() {
        do {
            let transactions = Table("transactions")
            let transactionId = Expression<String>("id")
            let date = Expression<String>("date")
            let amount = Expression<Double>("amount")
            
            try db?.run(transactions.createIndex(transactionId, unique: true, ifNotExists: true))
            try db?.run(transactions.createIndex(date, ifNotExists: true))
            try db?.run(transactions.createIndex(amount, ifNotExists: true))
            try db?.run(transactions.createIndex(date, amount, ifNotExists: true))

            print("indexes successfully created")
        } catch {
            print("Error creating indexes: \(error)")
        }
    }
    
    func getDBConnection() -> Connection? {
        return db
    }
    
    func clearDatabase() {
        let allTables = ["categories", "transactions"]
        let allIndexes = ["idx_transaction_id", "idx_date", "idx_amount"]
        
        do {
            for indexName in allIndexes {
                try db?.run("DROP INDEX IF EXISTS \(indexName)")
            }

            for tableName in allTables {
                try db?.run("DROP TABLE IF EXISTS \(tableName)")
            }
        } catch {
            print("Error clearing the database: \(error)")
        }
    }
    
    func reset() {
        clearDatabase()
        initializeTables()
        createIndexes()
    }
    
    enum DatabaseError: Error {
        case connectionError
        case idError
    }
}
