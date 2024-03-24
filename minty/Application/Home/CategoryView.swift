//
//  CategoryView.swift
//  minty
//
//  Created by Jacob Beene on 3/22/24.
//

import SwiftUI

struct CategoryView: View {
    @State private var categoryName: String = ""
    @Binding var categories: [Category]  // This will allow ContentView to pass its categories array

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $categoryName)
                Button("Add Category") {
                    addCategory()
                }
            }
            .navigationBarTitle("Add Category")
        }
    }
    
    private func addCategory() {
        let newCategory = Category(name: categoryName)
        categories.append(newCategory)
        // Reset input fields
        categoryName = ""
//        let _ = DatabaseManager.instance.addCategory(category: newCategory)
    }
}
