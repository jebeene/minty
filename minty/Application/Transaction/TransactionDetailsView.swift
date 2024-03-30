//
//  TransactionDetailsView.swift
//  minty
//
//  Created by Jacob Beene on 3/30/24.
//

import SwiftUI

struct TransactionDetailsView: View {
    var transaction: Transaction
    var categoryViewModel: CategoryViewModel
    var onDelete: () -> Void
    var onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(transaction.description)
                .font(.title)
                .bold()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Amount")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Text("$\(transaction.amount, specifier: "%.2f")")
                        .font(.subheadline)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Type")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Text("\(transaction.type)")
                        .font(.subheadline)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Date")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Text(transaction.date, style: .date)
                        .font(.subheadline)
                }
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Category")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Text(categoryViewModel.getCategoryName(byId: transaction.categoryId))
                        .font(.subheadline)
                }
            }

            Spacer()

            HStack {
                Button(action: onEdit) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                
                .padding()
                
                Button(action: onDelete) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                }
                .buttonStyle(DestructiveButtonStyle())
            }
            .font(.headline)
            .padding(.bottom)
        }
        .navigationBarTitle(Text("Transaction"), displayMode: .inline)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
