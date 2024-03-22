//
//  ContentView.swift
//  minty
//
//  Created by Jacob Beene on 1/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var transactionDescription = ""
    @State private var transactionAmount = ""
    @State private var selectedType = Transaction.TransactionType.income
    @State private var transactions = [Transaction]()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Transaction")) {
                    TextField("Description", text: $transactionDescription)
                    TextField("Amount", text: $transactionAmount)
                        .keyboardType(.decimalPad)
                    Picker("Type", selection: $selectedType) {
                        ForEach(Transaction.TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Button("Add Transaction") {
                        addTransaction()
                    }
                }
                

                Section(header: Text("Transactions")) {
                    List(transactions, id: \.description) { transaction in
                        VStack(alignment: .leading) {
                            Text(transaction.description)
                                .font(.headline)
                            Text("\(transaction.type.rawValue) - $\(transaction.amount, specifier: "%.2f")")
                                .font(.subheadline)
                        }
                    }
                }
                
            }
            .navigationBarTitle("minty")
            .navigationBarItems(trailing: Button("Clear Data") {
                        // This code is executed when the "Clear Data" button is tapped
                        let _ = DatabaseManager.instance.clearAllTransactions()
                        // Clear the local transactions array to update the UI
                        transactions.removeAll()
                    })
            .onAppear {
                loadTransactions()
            }
        }
    }

    private func addTransaction() {
        guard let amount = Double(transactionAmount),
              !transactionDescription.isEmpty else { return }
        let newTransaction = Transaction(description: transactionDescription, amount: amount, type: selectedType)
        // Add the transaction to the local array (if needed for UI update)
        transactions.append(newTransaction)
        // Reset input fields
        transactionDescription = ""
        transactionAmount = ""
        // Add the transaction to the database
        let _ = DatabaseManager.instance.addTransaction(transaction: newTransaction)
    }
    
    private func loadTransactions() {
           if let fetchedTransactions = DatabaseManager.instance.getAllTransactions() {
               transactions = fetchedTransactions
           }
    }
}
