//
//  FilterView.swift
//  minty
//
//  Created by Jacob Beene on 4/24/24.
//

import SwiftUI

struct FilterView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    @State private var showStartDatePicker: Bool = false
    @State private var showEndDatePicker: Bool = false
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var selectedMonth: String = ""
    @State private var selectedCategory: UUID?
    @State private var transactionType: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date Range")) {
                    DatePickerOptional("Start Date", prompt: "add", in: ...Date(), selection: $startDate)
                    DatePickerOptional("End Date", prompt: "add", in: ...Date(), selection: $endDate)
                }
                
                Picker("Category", selection: $selectedCategory) {
                    Text("All Categories").tag(UUID?.none)
                    ForEach(categoryViewModel.categories, id: \.id) { category in
                        Text(category.name).tag(category.id as UUID?)
                    }
                }
                
                Picker("Type", selection: $transactionType) {
                    Text("All").tag("")
                    Text("Expense").tag("expense")
                    Text("Income").tag("income")
                }
                
                Button("Apply Filters") {
                    applyFilters()
                }
            }
            .navigationBarTitle("Filter Transactions", displayMode: .inline)
        }
    }

    func getMonths() -> [String] {
        let months = transactionViewModel.transactions.map { transaction -> String in
            dateFormatter.string(from: transaction.date)
        }
        
        let uniqueMonths = Set(months)
        return Array(uniqueMonths).sorted()
    }

    func applyFilters() {
        transactionViewModel.filterTransactions(startDate: startDate, endDate: endDate, category: selectedCategory, type: transactionType)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func Binding<T>(_ binding: Binding<T?>, _ defaultValue: T) -> Binding<T> {
        SwiftUI.Binding(get: { binding.wrappedValue ?? defaultValue }, set: { binding.wrappedValue = $0 })
    }
}

