//
//  Transaction.swift
//  minty
//
//  Created by Jacob Beene on 1/11/24.
//

import Foundation

struct Transaction: Identifiable {
    var id = UUID()
    var date: Date
    var description: String
    var amount: Double
    var type: String
    var categoryId: UUID
}
