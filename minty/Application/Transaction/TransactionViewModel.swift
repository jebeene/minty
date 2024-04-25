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
    
    func filterTransactions(startDate: Date?, endDate: Date?, category: UUID?, type: String) {
        let calendar = Calendar.current
        var filteredTransactions = transactions
        isFiltering = (startDate != nil && endDate != nil) || category != nil || type != "All"
        if let startDate = startDate, let endDate = endDate {
            let startOfStartDay = calendar.startOfDay(for: startDate)
            let endOfEndDay = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: endDate) ?? endDate)
                   
            filteredTransactions = filteredTransactions.filter { transaction in
                transaction.date >= startOfStartDay && transaction.date <= endOfEndDay
            }
            print(startOfStartDay)
            print(endOfEndDay)
        }
        
        // Filter by category if not nil
        if let category = category {
            filteredTransactions = filteredTransactions.filter { transaction in
                transaction.categoryId == category
            }
        }
        
        // Filter by type if not empty
        if !type.isEmpty {
            filteredTransactions = filteredTransactions.filter { transaction in
                transaction.type.lowercased() == type.lowercased()
            }
        }
        
        // Update the grouped transactions based on the filters
        groupTransactions(filteredTransactions)
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
