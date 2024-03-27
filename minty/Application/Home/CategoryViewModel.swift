//
//  CategoryViewModel.swift
//  minty
//
//  Created by Jacob Beene on 3/24/24.
//

import Foundation

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    private var categoryManager = CategoryManager()

    init() {
        loadCategories()
    }
    
    // Load categories from the database through the CategoryManager
    func loadCategories() {
        do {
            categories = try categoryManager.getAllCategories()
        } catch {
            // Handle the error, e.g., by logging it or setting an error state
            print("Error loading categories: \(error)")
        }
    }

    // Add a category through the CategoryManager and reload the categories
    func addCategory(id: UUID, name: String) {
        do {
            let newCategory = Category(id: id, name: name)
            try categoryManager.addCategory(newCategory)
            loadCategories()
        } catch {
            print("Error adding category: \(error)")
        }
    }

    // Update a category through the CategoryManager and reload the categories
    func updateCategory(_ category: Category) {
        do {
            try categoryManager.updateCategory(category)
            loadCategories()
        } catch {
            print("Error updating category: \(error)")
        }
    }

    // Delete a category through the CategoryManager and reload the categories
    func deleteCategory(_ category: Category) {
        do {
            try categoryManager.deleteCategory(byId: category.id)
            loadCategories()
        } catch {
            print("Error deleting category: \(error)")
        }
    }
    
    func getCategoryName(byId id: UUID) -> String {
        if let category = categories.first(where: { $0.id == id }) {
            return category.name
        } else {
            return "Unknown Category"
        }
    }
}
