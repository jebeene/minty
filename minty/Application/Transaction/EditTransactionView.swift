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
    @State private var showAlert = false
    @State private var alertMessage = ""
    var onSave: () -> Void

    init(transactionViewModel: TransactionViewModel, categoryViewModel: CategoryViewModel, transaction: Transaction, onSave: @escaping () -> Void) {
        print("Initializing EditTransactionView with transaction: \(transaction)")
        _transaction = State(initialValue: transaction)
        _amount = State(initialValue: String(transaction.amount))
        _date = State(initialValue: transaction.date)
        _selectedCategoryId = State(initialValue: transaction.categoryId)
        _description = State(initialValue: transaction.description)
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
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Picker("Category", selection: $selectedCategoryId) {
                    ForEach(categoryViewModel.categories) { category in
                        Text(category.name).tag(category.id as UUID?)
                    }
                }
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

                    // Assuming transaction has properties amount, date, categoryId, description.
                    // Update the properties of the transaction with new values here.
                    transaction.amount = amountDouble
                    transaction.date = date
                    transaction.categoryId = categoryId
                    transaction.description = description

                    // Update the transaction using the ViewModel
                    transactionViewModel.updateTransaction(transaction)
                    onSave() // Call onSave closure to indicate save was successful
                }
            }
            .navigationBarTitle("Edit Transaction", displayMode: .inline)
            .onAppear {
                // Update the state variables with the transaction details
                self.amount = String(transaction.amount)
                self.date = transaction.date
                self.selectedCategoryId = transaction.categoryId
                self.description = transaction.description
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
