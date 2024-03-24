//import Foundation
//import SQLite
//
//class DatabaseManagerOLD {
//    static let instance = DatabaseManager()  // Singleton instance
//    private let db: Connection?
//
//    // TRANSACTION
//    private let transactions = Table("transactions")
//    private let id = Expression<Int>("id")
//    private let description = Expression<String>("description")
//    private let amount = Expression<Double>("amount")
//    private let type = Expression<String>("type")
//
//    // CATEGORY
//    private let categories = Table("categories")
//    private let categoryId = Expression<Int>("category_id")
//    private let name = Expression<String>("name")
//
//    private init() {
//        let path = NSSearchPathForDirectoriesInDomains(
//            .documentDirectory, .userDomainMask, true
//        ).first!
//
//        do {
//            db = try Connection("\(path)/minty.sqlite3")
//            createTransactionTable()
//            createCategoryTable()
//        } catch {
//            db = nil
//            print("Unable to open database")
//        }
//    }
//
//    private func createTransactionTable() {
//        do {
//            try db?.run(transactions.create(ifNotExists: true) { t in
//                t.column(id, primaryKey: .autoincrement)
//                t.column(description)
//                t.column(amount)
//                t.column(type)
//                t.column(categoryId)
//
//            })
//        } catch {
//            print("Unable to create transaction table \(error)")
//        }
//    }
//
//    func addTransaction(transaction: Transaction) -> Int64? {
//        do {
//            let insert = transactions.insert(
//                self.description <- transaction.description,
//                self.amount <- transaction.amount,
//                self.type <- transaction.type.rawValue,
//                self.categoryId <- transaction.categoryId
//            )
//            let id = try db?.run(insert)
//            return id
//        } catch {
//            print("Insert failed")
//            return nil
//        }
//    }
//
//    func getAllTransactions() -> [Transaction]? {
//        do {
//            guard let db = db else { return nil }
//            var transactionList = [Transaction]()
//
//            let categoriesDict = getAllCategories()
//
//            for transaction in try db.prepare(self.transactions) {
//                let transactionType = Transaction.TransactionType(rawValue: transaction[type]) ?? .expense  // Default to expense if not found
//                let categoryName = categoriesDict[transaction[categoryId]]
//
//                transactionList.append(Transaction(
//                    id: transaction[id],
//                    description: transaction[description],
//                    amount: transaction[amount],
//                    type: transactionType,
//                    categoryId: transaction[categoryId],
//                    categoryName: categoryName
//                ))
//            }
//            return transactionList
//        } catch {
//            print("Select failed")
//            return nil
//        }
//    }
//
//    func deleteTransaction(transactionId: Int) -> Bool {
//        do {
//            let transaction = transactions.filter(id == transactionId)
//            try db?.run(transaction.delete())
//            return true
//        } catch {
//            print("Delete failed")
//            return false
//        }
//    }
//
//    func updateTransaction(transaction: Transaction) -> Bool {
//        guard let transactionId = transaction.id else { return false }
//        do {
//            let dbTransaction = transactions.filter(id == transactionId)
//            try db?.run(dbTransaction.update(
//                description <- transaction.description,
//                amount <- transaction.amount,
//                type <- transaction.type.rawValue
//            ))
//            return true
//        } catch {
//            print("Update failed")
//            return false
//        }
//    }
//
//    func clearAllTransactions() -> Bool {
//        do {
//            // Attempt to delete all rows from the transactions table
//            let deleteAll = self.transactions.delete()
//            try db?.run(deleteAll)
//            return true
//        } catch {
//            print("Clear all transactions failed: \(error)")
//            return false
//        }
//    }
//
//    func createCategoryTable() {
//        do {
//            try db?.run(categories.create(ifNotExists: true) { t in
//                t.column(categoryId, primaryKey: .autoincrement)
//                t.column(name, unique: true)
//            })
//        } catch {
//            print("Unable to create categories table: \(error)")
//        }
//    }
//
//    func addCategory(category: Category) -> Int64? {
//        do {
//            let insert = categories.insert(
//                self.name <- category.name
//            )
//            let id = try db?.run(insert)
//            return id
//        } catch {
//            print("Insert category failed: \(error)")
//            return nil
//        }
//    }
//
//    func getAllCategories() -> [Int: String] {
//        var categoriesDict = [Int: String]()
//
//        do {
//            guard let db = db else { return categoriesDict }
//
//            for category in try db.prepare(self.categories) {
//                categoriesDict[category[categoryId]] = category[name]
//            }
//            return categoriesDict
//        } catch {
//            print("Select failed")
//            return categoriesDict
//        }
//    }
//}
//
