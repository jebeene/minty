//
//  TransactionViewModel.swift
//  minty
//
//  Created by Jacob Beene on 3/23/24.
//

import Foundation

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    private var transactionManager = TransactionManager()

    init() {
        loadTransactions()
    }
    
    // Load transactions from the database through the TransactionManager
    func loadTransactions() {
        do {
           transactions = try transactionManager.getAllTransactions()
       } catch {
           // Handle the error, e.g., by logging it or setting an error state
           print("Error loading transactions: \(error)")
       }
    }

    // Add a transaction through the TransactionManager and reload the transactions
    func addTransaction(description: String, amount: Double, type: String, categoryId: UUID) {
        do {
            let newTransaction = Transaction(description: description, amount: amount, type: type, categoryId: categoryId)
            try transactionManager.addTransaction(newTransaction)
            loadTransactions()
        } catch {
            print("Error adding transaction: \(error)")
        }
    }

    // Update a transaction through the TransactionManager and reload the transactions
    func updateTransaction(_ transaction: Transaction) {
        do {
            try transactionManager.updateTransaction(transaction)
            loadTransactions()
        } catch {
            print("Error updating transaction: \(error)")
        }
    }

    // Delete a transaction through the TransactionManager and reload the transactions
    func deleteTransaction(_ transaction: Transaction) {
        do {
            try transactionManager.deleteTransaction(byId: transaction.id)
            loadTransactions()
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }
}
