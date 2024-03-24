//
//  CategoryManager.swift
//  minty
//
//  Created by Jacob Beene on 3/23/24.
//

import Foundation
import SQLite

class CategoryManager {
    static let instance = CategoryManager()
    private let categories = Table("categories")
    private let db = DatabaseManager.instance.getDBConnection()
    
    func createTable() throws {
        try db?.run(categories.create(ifNotExists: true) { t in
            t.column(Expression<Int>("id"), primaryKey: true)
            t.column(Expression<String>("name"))
        })
    }

    // Add methods for insert, query, update, delete
    
    func addCategory(_ category: Category) throws {
        guard let db = db else { throw DatabaseManager.DatabaseError.connectionError }
        let insert = categories.insert(
            Expression<String>("name") <- category.name
        )
        try db.run(insert)
    }
    
    func getAllCategories() throws -> [Category] {
        guard let db = db else { throw DatabaseManager.DatabaseError.connectionError }
        var categoryList = [Category]()
        for category in try db.prepare(categories) {
            let loadedCategory = Category(
                id: category[Expression<UUID>("id")],
                name: category[Expression<String>("name")]
            )
            categoryList.append(loadedCategory)
        }
        return categoryList
    }
    
    func updateCategory(_ category: Category) throws {
        guard let db = db else { throw DatabaseManager.DatabaseError.connectionError }
        let categoryRow = categories.filter(Expression<UUID>("id") == category.id)
        let update = categoryRow.update([
            Expression<String>("name") <- category.name
        ])
        try db.run(update)
    }
    
    func deleteCategory(byId id: Int) throws {
        guard let db = db else { throw DatabaseManager.DatabaseError.connectionError }
        let categoryRow = categories.filter(Expression<Int>("id") == id)
        try db.run(categoryRow.delete())
    }
    
}
