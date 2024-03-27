//
//  ContentView.swift
//  minty
//
//  Created by Jacob Beene on 1/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var transactionViewModel = TransactionViewModel()
    @StateObject var categoryViewModel = CategoryViewModel()
    @State private var showingAddTransaction = false
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            Group {
                if transactionViewModel.transactions.isEmpty {
                    NoTransactionsView() // Custom view for no transactions
                } else {
                    TransactionsListView(transactionViewModel: transactionViewModel, transactions: transactionViewModel.transactions) // List view for transactions
                }
            }
            .navigationBarTitle("minty")
            .navigationBarItems(leading: clearDataButton, trailing: addTransactionButton)
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(transactionViewModel: transactionViewModel, categoryViewModel: categoryViewModel)
            }
            .alert(isPresented: $showingAlert) { clearDataAlert }
        }
    }

    private var clearDataButton: some View {
        Button("Clear Data") {
            showingAlert = true
        }
    }

    private var addTransactionButton: some View {
        Button(action: {
            showingAddTransaction = true
        }) {
            Image(systemName: "plus")
        }
    }

    private var clearDataAlert: Alert {
        Alert(
            title: Text("Confirm"),
            message: Text("Are you sure you want to clear all data?"),
            primaryButton: .destructive(Text("Clear")) {
                DatabaseManager.instance.clearDatabase()
                DatabaseManager.instance.initializeTables()
                transactionViewModel.loadTransactions()
                categoryViewModel.loadCategories()
            },
            secondaryButton: .cancel()
        )
    }
}

struct NoTransactionsView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No transactions")
                .foregroundColor(.gray) // Optional: Change the color if you wish
            Spacer()
        }
        .frame(maxWidth: .infinity) // Expand the VStack to fill the available width
    }
}

struct TransactionsListView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    var transactions: [Transaction]
    
    var body: some View {
        List {
            ForEach(transactions, id: \.id) { transaction in
                TransactionRow(transaction: transaction)
            }
            .onDelete(perform: deleteTransactions)
        }
    }
    
    private func deleteTransactions(at offsets: IndexSet) {
        offsets.forEach { index in
            let transaction = transactions[index]
            transactionViewModel.deleteTransaction(transaction)
        }
        // Reload transactions to reflect the changes
        transactionViewModel.loadTransactions()
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
    @ObservedObject var categoryViewModel: CategoryViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var type: String = "Expense"
    @State private var selectedCategoryId: UUID? = nil
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

                // Updated picker for selecting category
                Picker("Category", selection: $selectedCategoryId) {
                    ForEach(categoryViewModel.categories) { category in
                        Text(category.name).tag(category.id as UUID?) // Ensuring type consistency
                    }
                }.onAppear {
                    if let firstCategoryId = categoryViewModel.categories.first?.id {
                        selectedCategoryId = firstCategoryId
                    }
                }

                Button("Add Category") {
                    showingAddCategory = true
                }
                .sheet(isPresented: $showingAddCategory) {
                    AddCategoryView(categoryViewModel: categoryViewModel) { newCategoryId in
                        selectedCategoryId = newCategoryId
                        categoryViewModel.loadCategories()
                    }
                }

                Button("Save") {
                    // Validation and saving logic here
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

                    transactionViewModel.addTransaction(description: description, amount: amountDouble, type: type, categoryId: categoryId)
                    presentationMode.wrappedValue.dismiss()
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
    @ObservedObject var categoryViewModel: CategoryViewModel
    @State private var categoryName: String = ""
    @Environment(\.presentationMode) var presentationMode

    // Add a completion handler to pass back the new category ID
    var onCategoryAdded: (UUID) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Category Name", text: $categoryName)
                Button("Save") {
                    let newCategoryId = UUID() // Generate a new UUID for the category
                    categoryViewModel.addCategory(id: newCategoryId, name: categoryName)
                    onCategoryAdded(newCategoryId) // Pass the new category ID back
                    presentationMode.wrappedValue.dismiss() // Dismiss after saving
                }
            }
            .navigationBarTitle("Add Category", displayMode: .inline)
        }
    }
}
