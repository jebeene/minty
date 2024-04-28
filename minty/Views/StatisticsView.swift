//
//  StatisticsView.swift
//  minty
//
//  Created by Jacob Beene on 4/27/24.
//

import SwiftUI

struct StatisticsView: View {
    var totalAmount: Double
    var averageAmount: Double
    var highestTransaction: Double
    var lowestTransaction: Double
    var transactionCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transaction Statistics")
                .font(.headline)
                .padding(.bottom, 5)
            
            HStack {
                StatisticLabel(title: "Total", value: String(format: "$%.2f", totalAmount))
                Spacer()
                StatisticLabel(title: "Average", value: String(format: "$%.2f", averageAmount))
            }
            
            HStack {
                StatisticLabel(title: "Highest", value: String(format: "$%.2f", highestTransaction))
                Spacer()
                StatisticLabel(title: "Lowest", value: String(format: "$%.2f", lowestTransaction))
            }
            
            Text("Total Transactions: \(transactionCount)")
                .font(.subheadline)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.horizontal)
    }
}

struct StatisticLabel: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .bold()
        }
    }
}
