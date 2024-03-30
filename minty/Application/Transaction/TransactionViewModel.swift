//
//  TransactionViewModel.swift
//  minty
//
//  Created by Jacob Beene on 3/23/24.
//

import Foundation

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var groupedTransactions: [String: [Transaction]] = [:]
    private var transactionManager = TransactionManager()

    private func groupTransactions() {
        // Grouping transactions by month and year. Replace `transaction.date` with your date property.
        let grouped = Dictionary(grouping: transactions) { (transaction) -> String in
            let date = transaction.date // Replace with your date property
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
        self.groupedTransactions = grouped
    }
    
    // Call this method after fetching transactions
    init() {
        loadTransactions() // Load your transactions, then:
        groupTransactions() // Group them by month and year
    }
    
    // Load transactions from the database through the TransactionManager
    func loadTransactions() {
        do {
            transactions = try transactionManager.getAllTransactions()
            groupTransactions()
       } catch {
           // Handle the error, e.g., by logging it or setting an error state
           print("Error loading transactions: \(error)")
       }
    }

    // Add a transaction through the TransactionManager and reload the transactions
    func addTransaction(date: Date, description: String, amount: Double, type: String, categoryId: UUID) {
        do {
            let newTransaction = Transaction(date: date, description: description, amount: amount, type: type, categoryId: categoryId)
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
    func deleteTransaction(byId id: UUID) {
        do {
            try transactionManager.deleteTransaction(byId: id)
            loadTransactions()
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }
}
