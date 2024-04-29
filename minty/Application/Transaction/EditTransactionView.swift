//
//  EditTransactionView.swift
//  minty
//
//  Created by Jacob Beene on 3/30/24.
//

import SwiftUI

struct EditTransactionView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    @State private var transaction: Transaction
    @State private var amount: String
    @State private var date: Date
    @State private var selectedCategoryId: UUID?
    @State private var description: String
    @State private var type: String
    @State private var showAlert = false
    @State private var alertMessage = ""
    var onSave: () -> Void

    init(transactionViewModel: TransactionViewModel, categoryViewModel: CategoryViewModel, transaction: Transaction, onSave: @escaping () -> Void) {
        print("Initializing EditTransactionView with transaction: \(transaction)")
        _transaction = State(initialValue: transaction)
        _description = State(initialValue: transaction.description)
        _amount = State(initialValue: String(transaction.amount))
        _type = State(initialValue: String(transaction.type))
        _date = State(initialValue: transaction.date)
        _selectedCategoryId = State(initialValue: transaction.categoryId)
        self.transactionViewModel = transactionViewModel
        self.categoryViewModel = categoryViewModel
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Description", text: $description)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                Picker("Type", selection: $type) {
                    Text("Income").tag("Income")
                    Text("Expense").tag("Expense")
                }.pickerStyle(SegmentedPickerStyle())
                Picker("Category", selection: $selectedCategoryId) {
                    ForEach(categoryViewModel.categories) { category in
                        Text(category.name).tag(category.id as UUID?)
                    }
                }
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Button("Save") {
                    guard let amountDouble = Double(amount), amountDouble > 0 else {
                        alertMessage = "Invalid amount. Please enter a numeric value."
                        showAlert = true
                        return
                    }

                    guard let categoryId = selectedCategoryId else {
                        alertMessage = "Please select a category."
                        showAlert = true
                        return
                    }
                    
                    transaction.description = description
                    transaction.amount = amountDouble
                    transaction.type = type
                    transaction.date = date
                    transaction.categoryId = categoryId

                    transactionViewModel.updateTransaction(transaction)
                    onSave()
                }
            }
            .navigationBarTitle("Edit Transaction", displayMode: .inline)
            .onAppear {
                self.description = transaction.description
                self.amount = String(transaction.amount)
                self.type = transaction.type
                self.date = transaction.date
                self.selectedCategoryId = transaction.categoryId
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Input Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
