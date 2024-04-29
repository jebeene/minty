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
    
    func loadCategories() {
        do {
            categories = try categoryManager.getAllCategories()
        } catch {
            print("Error loading categories: \(error)")
        }
    }

    func addCategory(id: UUID, name: String) {
        do {
            let newCategory = Category(id: id, name: name)
            try categoryManager.addCategory(newCategory)
            loadCategories()
        } catch {
            print("Error adding category: \(error)")
        }
    }

    func updateCategory(_ category: Category) {
        do {
            try categoryManager.updateCategory(category)
            loadCategories()
        } catch {
            print("Error updating category: \(error)")
        }
    }

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
