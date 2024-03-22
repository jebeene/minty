//
//  Transaction.swift
//  minty
//
//  Created by Jacob Beene on 1/11/24.
//

import Foundation

struct Transaction {
    var id: Int64? // Added ID field
    var description: String
    var amount: Double
    var type: TransactionType

    enum TransactionType: String, CaseIterable, Identifiable {
        case income = "Income"
        case expense = "Expense"

        var id: String { self.rawValue }
    }
}
