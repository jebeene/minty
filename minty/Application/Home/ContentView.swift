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
    
    @State private var showingFilterView = false

    var body: some View {
        NavigationView {
            List {
                if transactionViewModel.transactions.isEmpty {
                    NoTransactionsView() // Display this view when there are no transactions
                } else {
                    ForEach(Array(transactionViewModel.groupedTransactions.keys), id: \.self) { key in
                        if let transactions = transactionViewModel.groupedTransactions[key] {
                            ForEach(transactions) { transaction in
                                if let transactions = transactionViewModel.groupedTransactions[key] {
                                    TransactionsSectionView(monthYear: key, transactions: transactions, categoryViewModel: categoryViewModel, transactionViewModel: transactionViewModel)
                                }
                            }
                            .onDelete(perform: { indexSet in
                                // Handle direct deletion from the list, if applicable
                            })
                        }
                    }
                }
            }
            .navigationBarTitle("transactions")
            .navigationBarItems(
                leading: clearDataButton,
                trailing: HStack {
                    filterButton
                    addTransactionButton
                }
            )            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(transactionViewModel: transactionViewModel, categoryViewModel: categoryViewModel)
            }
            .sheet(isPresented: $showingFilterView) {
                FilterView(transactionViewModel: transactionViewModel, categoryViewModel: categoryViewModel)
            }
            
            .alert(isPresented: $showingAlert) { clearDataAlert }
        }
    }

    private var filterButton: some View {
        Button(action: { showingFilterView.toggle() }) {
            Image(systemName: "line.horizontal.3.decrease.circle")
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

struct TransactionsSectionView: View {
    var monthYear: String
    var transactions: [Transaction]
    var categoryViewModel: CategoryViewModel
    var transactionViewModel: TransactionViewModel
    
    @State private var selectedTransaction: Transaction?
    @State private var editingTransaction: Transaction? = nil
    @State private var showingEditTransactionView = false
    @State private var isEditingTransaction = false // New state to control the sheet presentation
    
    var body: some View {
        Section(header: Text(monthYear).font(.title3).fontWeight(.bold)) {
            ForEach(transactions, id: \.id) { transaction in
                NavigationLink(destination: TransactionDetailsView(transaction: transaction, categoryViewModel: categoryViewModel, onDelete: {
                    self.transactionViewModel.deleteTransaction(byId: transaction.id)
                }, onEdit: {
                    self.selectedTransaction = transaction
                    print("Selected transaction for editing: \(String(describing: self.selectedTransaction))")
                    self.isEditingTransaction = true

                }
                )) {
                    TransactionRow(transaction: transaction, categoryViewModel: categoryViewModel)
                }
            }
            .onDelete(perform: deleteTransactions)
        }
        .sheet(isPresented: $isEditingTransaction, onDismiss: {
            self.selectedTransaction = nil // Clear selected transaction on dismiss
        }) {
            // Since we know selectedTransaction is set when isEditingTransaction is true, force unwrap is safer here
            // For more safety, fallback to EmptyView as a precaution
            if let transactionToEdit = self.selectedTransaction {
                EditTransactionView(transactionViewModel: transactionViewModel, categoryViewModel: categoryViewModel, transaction: transactionToEdit, onSave: {
                    self.isEditingTransaction = false
                })
            } else {
                EmptyView()
            }
        }
    }
    
    private func deleteTransactions(at offsets: IndexSet) {
        offsets.forEach { index in
            let transaction = transactions[index]
            transactionViewModel.deleteTransaction(byId: transaction.id)
        }
        // Reload transactions to reflect the changes
        transactionViewModel.loadTransactions()
    }
}

struct TransactionRow: View {
    var transaction: Transaction
    var categoryViewModel: CategoryViewModel
    static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium // Or your custom format
            formatter.timeStyle = .none
            return formatter
        }()
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.description)
                    .bold()
                Text(categoryViewModel.getCategoryName(byId: transaction.categoryId))
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(TransactionRow.dateFormatter.string(from: transaction.date))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(5)
            Spacer()
            Text("$\(transaction.amount, specifier: "%.2f")")
                .font(.body)
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                .foregroundColor(.black)
                .background(transaction.type == "Expense" ? Color.red.opacity(0.6) : Color.green.opacity(0.6))
                .cornerRadius(5)
        }
    }
}

struct AddTransactionView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate: Date = Date()
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

                Picker("Category", selection: $selectedCategoryId) {
                    ForEach(categoryViewModel.categories) { category in
                        Text(category.name).tag(category.id as UUID?)
                    }
                }.onAppear {
                    if let firstCategoryId = categoryViewModel.categories.first?.id {
                        selectedCategoryId = firstCategoryId
                    }
                }

                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    .padding()

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

                    transactionViewModel.addTransaction(date: selectedDate, description: description, amount: amountDouble, type: type, categoryId: categoryId)
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
