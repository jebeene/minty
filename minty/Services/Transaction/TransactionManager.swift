//
//  TransactionManager.swift
//  minty
//
//  Created by Jacob Beene on 3/23/24.
//

import Foundation
import SQLite

class TransactionManager {
    static let instance = TransactionManager()
    private let transactions = Table("transactions")
    private let db = DatabaseManager.instance.getDBConnection()
    
    func createTable() throws {
        try db?.run(transactions.create(ifNotExists: true) { t in
            t.column(Expression<String>("id"), primaryKey: true)
            t.column(Expression<String>("date"))
            t.column(Expression<String>("description"))
            t.column(Expression<Double>("amount"))
            t.column(Expression<String>("type"))
            t.column(Expression<String>("categoryId"))
        })
    }

    // Add methods for insert, query, update, delete
    
    func addTransaction(_ transaction: Transaction) throws {
        guard let db = db else { throw DatabaseManager.DatabaseError.connectionError }
        let insert = transactions.insert(
            Expression<String>("id") <- UUID().uuidString,
            Expression<String>("date") <- ISO8601DateFormatter().string(from: transaction.date),
            Expression<String>("description") <- transaction.description,
            Expression<Double>("amount") <- transaction.amount,
            Expression<String>("type") <- transaction.type,
            Expression<String>("categoryId") <- transaction.categoryId.uuidString
        )
        try db.run(insert)
    }
    
    func getAllTransactions() throws -> [Transaction] {
        var transactionList = [Transaction]()

        guard let db = db else { return transactionList }
        
        for transactionRow in try db.prepare(self.transactions) {
            guard let id = UUID(uuidString: (try transactionRow.get(Expression<String>("id")))) else {
                print("Skipping a transaction due to bad id!")
                continue
            }

            guard let date = ISO8601DateFormatter().date(from: transactionRow[Expression<String>("date")]) else {
                print("Skipping a transaction due to bad date!")
                continue
            }
            
            
            guard let categoryId = UUID(uuidString: transactionRow[Expression<String>("categoryId")]) else {
                print("Skipping a transaction due to bad category id!")
                continue
            }
                    
            let loadedTransaction = Transaction(
                id: id,
                date: date,
                description: transactionRow[Expression<String>("description")],
                amount: transactionRow[Expression<Double>("amount")],
                type: transactionRow[Expression<String>("type")],
                categoryId: categoryId
            )
            transactionList.append(loadedTransaction)
        }
        return transactionList
    }
   
    func updateTransaction(_ transaction: Transaction) throws {
        guard let db = db else { throw DatabaseManager.DatabaseError.connectionError }
        
        let transactionRow = transactions.filter(Expression<String>("id") == transaction.id.uuidString)
        let update = transactionRow.update([
            Expression<String>("date") <- ISO8601DateFormatter().string(from: transaction.date),
            Expression<String>("description") <- transaction.description,
            Expression<Double>("amount") <- transaction.amount,
            Expression<String>("type") <- transaction.type,
            Expression<String>("categoryId") <- transaction.categoryId.uuidString
        ])
        try db.run(update)
    }
    
    func deleteTransaction(byId id: UUID) throws {
        guard let db = db else { throw DatabaseManager.DatabaseError.connectionError }
        let transactionRow = transactions.filter(Expression<String>("id") == id.uuidString)
        try db.run(transactionRow.delete())
    }
}
