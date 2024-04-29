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
            t.column(Expression<String>("id"), primaryKey: true)
            t.column(Expression<String>("name"))
        })
    }

    func addCategory(_ category: Category) throws {
        guard let db = db else { throw DatabaseManager.DatabaseError.connectionError }
        let insert = categories.insert(
            Expression<String>("id") <- category.id.uuidString,
            Expression<String>("name") <- category.name
        )
        try db.run(insert)
    }

    func getAllCategories() throws -> [Category] {
        var categoryList = [Category]()

        guard let db = db else { return categoryList }

        for categoryRow in try db.prepare(self.categories) {
            guard let id = UUID(uuidString: (try categoryRow.get(Expression<String>("id")))) else {
                print("Skipping an id!")
                continue
            }
            let name = try categoryRow.get(Expression<String>("name"))

            categoryList.append(Category(
                id: id,
                name: name
            ))
        }
        return categoryList
    }
    
    func updateCategory(_ category: Category) throws {
        guard let db = db else { throw DatabaseManager.DatabaseError.connectionError }
        let categoryRow = categories.filter(Expression<String>("id") == category.id.uuidString)
        let update = categoryRow.update([
            Expression<String>("name") <- category.name
        ])
        try db.run(update)
    }
    
    func deleteCategory(byId id: UUID) throws {
        guard let db = db else { throw DatabaseManager.DatabaseError.connectionError }
        let categoryRow = categories.filter(Expression<String>("id") == id.uuidString)
        try db.run(categoryRow.delete())
    }
    
}
