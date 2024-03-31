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
        let grouped = Dictionary(grouping: transactions) { (transaction) -> String in
            let date = transaction.date
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
        self.groupedTransactions = grouped
    }
    
    init() {
        loadTransactions()
        groupTransactions()
    }
    
    func loadTransactions() {
        do {
            transactions = try transactionManager.getAllTransactions()
            groupTransactions()
       } catch {
           print("Error loading transactions: \(error)")
       }
    }

    func addTransaction(date: Date, description: String, amount: Double, type: String, categoryId: UUID) {
        do {
            let newTransaction = Transaction(date: date, description: description, amount: amount, type: type, categoryId: categoryId)
            try transactionManager.addTransaction(newTransaction)
            loadTransactions()
        } catch {
            print("Error adding transaction: \(error)")
        }
    }

    func updateTransaction(_ transaction: Transaction) {
        do {
            try transactionManager.updateTransaction(transaction)
            loadTransactions()
        } catch {
            print("Error updating transaction: \(error)")
        }
    }

    func deleteTransaction(byId id: UUID) {
        do {
            try transactionManager.deleteTransaction(byId: id)
            loadTransactions()
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }
}
