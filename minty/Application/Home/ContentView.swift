//
//  ContentView.swift
//  minty
//
//  Created by Jacob Beene on 1/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var transactionViewModel = TransactionViewModel()
    @State private var showingAddTransaction = false  // To control the add transaction view presentation

    var body: some View {
        NavigationView {
            List(transactionViewModel.transactions) { transaction in
                TransactionRow(transaction: transaction)
            }
            .navigationBarTitle("Transactions")
            .navigationBarItems(trailing: Button(action: {
                showingAddTransaction = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(transactionViewModel: transactionViewModel)
            }
        }
    }
}

struct TransactionRow: View {
    var transaction: Transaction

    var body: some View {
        HStack {
            Text(transaction.description)
            Spacer()
            Text("$\(transaction.amount, specifier: "%.2f")")
                .foregroundColor(transaction.type == "Expense" ? .red : .green)
        }
    }
}

struct AddTransactionView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var type: String = "Expense"
    @State private var selectedCategoryId: UUID? = nil // Ensure this aligns with your category IDs
    @State private var showingAddCategory = false
    @State private var showAlert = false
    @State private var alertMessage = ""


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
                    ForEach(transactionViewModel.categories) { category in
                        Text(category.name).tag(category.id as UUID?) // Cast to UUID?
                    }
                }

                Button("Add Category") {
                    showingAddCategory = true
                }
                .sheet(isPresented: $showingAddCategory) {
                    AddCategoryView(transactionViewModel: transactionViewModel)
                }

                Button("Save") {
                    // Validate the 'amount' and convert it to Double
                    guard let amountDouble = Double(amount) else {
                        alertMessage = "Invalid amount. Please enter a numeric value."
                        showAlert = true
                        return
                    }

                    // Ensure a category has been selected
                    guard let categoryId = selectedCategoryId else {
                        alertMessage = "No category selected. Please select a category."
                        showAlert = true
                        return
                    }

                    // Both checks passed, add the transaction
                    transactionViewModel.addTransaction(description: description,
                                                        amount: amountDouble,
                                                        type: type,
                                                        categoryId: categoryId)
                }
            }
            .navigationBarTitle("Add Transaction", displayMode: .inline)
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

struct AddCategoryView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @State private var categoryName: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Category Name", text: $categoryName)
                Button("Save") {
                    // Add category saving logic here
                    // For now, just dismiss
                }
            }
            .navigationBarTitle("Add Category", displayMode: .inline)
        }
    }
}

