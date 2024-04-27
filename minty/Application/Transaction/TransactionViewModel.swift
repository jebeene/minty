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
    @Published var isFiltering: Bool = false
    private var transactionManager = TransactionManager()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    private func groupTransactions() {
        let sortedTransactions = transactions.sorted(by: { $0.date > $1.date })
        let grouped = Dictionary(grouping: sortedTransactions) { (transaction) -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: transaction.date)
        }
        self.groupedTransactions = grouped
    }

    
//    private func groupTransactions() {
//        let grouped = Dictionary(grouping: transactions) { (transaction) -> String in
//            let date = transaction.date
//            let formatter = DateFormatter()
//            formatter.dateFormat = "MMMM yyyy"
//            return formatter.string(from: date)
//        }
//        self.groupedTransactions = grouped
//    }
    
    init() {
        loadTransactions()
        groupTransactions()
    }
    
    func loadTransactions() {
        do {
            transactions = try transactionManager.getAllTransactions()
            groupTransactions(transactions)
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
    
    func filterTransactions(startDate: Date?, endDate: Date?, category: UUID?, type: String) {
        do {
            try transactions = transactionManager.filterTransactions(startDate: startDate, endDate: endDate, category: category, type: type)
            isFiltering = true
            groupTransactions(transactions)
        } catch {
            print("Error filtering transactions: \(error)")
        }
    }

    func clearFilters() {
        isFiltering = false
        loadTransactions()
    }
    
    private func groupTransactions(_ transactions: [Transaction]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let grouped = Dictionary(grouping: transactions) { transaction in
            dateFormatter.string(from: transaction.date)
        }
        self.groupedTransactions = grouped
    }

}
