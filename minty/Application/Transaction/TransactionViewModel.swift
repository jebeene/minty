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
    
    @Published var creditsTotal: Double = 0.0
    @Published var debitsTotal: Double = 0.0
    @Published var averageAmount: Double = 0.0
    @Published var highestTransaction: Double = 0.0
    @Published var lowestTransaction: Double = 0.0
    @Published var transactionCount: Int = 0

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
    
    func filterTransactions(startDate: Date?, endDate: Date?, category: UUID?, type: String, minimumAmount: Double?, maximumAmount: Double?) {
        do {
            try transactions = transactionManager.filterTransactions(
                startDate: startDate,
                endDate: endDate,
                category: category,
                type: type,
                minimumAmount: minimumAmount,
                maximumAmount: maximumAmount
            )
            isFiltering = true
            groupTransactions()
            calculateStatistics(transactions)
        } catch {
            print("Error filtering transactions: \(error)")
        }
    }

    func clearFilters() {
        isFiltering = false
        loadTransactions()
    }
    
    private func calculateStatistics(_ transactions: [Transaction]) {
        transactionCount = transactions.count

        let credits = transactions
            .filter { $0.type.lowercased() == "income" }
            .reduce(0) { $0 + $1.amount }

        let debits = transactions
            .filter { $0.type.lowercased() == "expense" }
            .reduce(0) { $0 + $1.amount }

        averageAmount = transactions.isEmpty ? 0 : (credits - debits) / Double(transactionCount)
        highestTransaction = transactions.max(by: { $0.amount < $1.amount })?.amount ?? 0
        lowestTransaction = transactions.min(by: { $0.amount < $1.amount })?.amount ?? 0

        self.creditsTotal = credits
        self.debitsTotal = debits
    }

    
}
