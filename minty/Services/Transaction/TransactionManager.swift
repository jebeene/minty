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
            Expression<String>("description") <- transaction.description,
            Expression<Double>("amount") <- transaction.amount,
            Expression<String>("type") <- transaction.type,
            Expression<String>("categoryId") <- transaction.categoryId.uuidString
        )
        try db.run(insert)
    }
    
    func getAllTransactions() throws -> [Transaction] {
        guard let db = db else { throw DatabaseManager.DatabaseError.connectionError }
        var transactionList = [Transaction]()
        for transaction in try db.prepare(transactions) {
            guard let transactionId = UUID(uuidString: transaction[Expression<String>("id")]) else {
                throw DatabaseManager.DatabaseError.idError
            }
            
            guard let categoryId = UUID(uuidString: transaction[Expression<String>("categoryId")]) else {
                throw DatabaseManager.DatabaseError.idError
            }
                    
            let loadedTransaction = Transaction(
                id: transactionId,
                description: transaction[Expression<String>("description")],
                amount: transaction[Expression<Double>("amount")],
                type: transaction[Expression<String>("type")],
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
