import Foundation
import SQLite

class DatabaseManager {
    static let instance = DatabaseManager()  // Singleton instance
    private let db: Connection?

    private let transactions = Table("transactions")
    private let id = Expression<Int64>("id")
    private let description = Expression<String>("description")
    private let amount = Expression<Double>("amount")
    private let type = Expression<String>("type")

    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!

        do {
            db = try Connection("\(path)/minty.sqlite3")
            createTable()
        } catch {
            db = nil
            print("Unable to open database")
        }
    }

    private func createTable() {
        do {
            try db?.run(transactions.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(description)
                t.column(amount)
                t.column(type)
            })
        } catch {
            print("Unable to create table")
        }
    }

    func addTransaction(transaction: Transaction) -> Int64? {
        do {
            let insert = transactions.insert(
                self.description <- transaction.description,
                self.amount <- transaction.amount,
                self.type <- transaction.type.rawValue
            )
            let id = try db?.run(insert)
            return id
        } catch {
            print("Insert failed")
            return nil
        }
    }

    func getAllTransactions() -> [Transaction]? {
        do {
            guard let db = db else { return nil }
            var transactionList = [Transaction]()

            for transaction in try db.prepare(self.transactions) {
                let transactionType = Transaction.TransactionType(rawValue: transaction[type]) ?? .expense  // Default to expense if not found
                transactionList.append(Transaction(
                    id: transaction[id],
                    description: transaction[description],
                    amount: transaction[amount],
                    type: transactionType
                ))
            }
            return transactionList
        } catch {
            print("Select failed")
            return nil
        }
    }

    func deleteTransaction(transactionId: Int64) -> Bool {
        do {
            let transaction = transactions.filter(id == transactionId)
            try db?.run(transaction.delete())
            return true
        } catch {
            print("Delete failed")
            return false
        }
    }

    func updateTransaction(transaction: Transaction) -> Bool {
        guard let transactionId = transaction.id else { return false }
        do {
            let dbTransaction = transactions.filter(id == transactionId)
            try db?.run(dbTransaction.update(
                description <- transaction.description,
                amount <- transaction.amount,
                type <- transaction.type.rawValue
            ))
            return true
        } catch {
            print("Update failed")
            return false
        }
    }
    
    func clearAllTransactions() -> Bool {
        do {
            // Attempt to delete all rows from the transactions table
            let deleteAll = self.transactions.delete()
            try db?.run(deleteAll)
            return true
        } catch {
            print("Clear all transactions failed: \(error)")
            return false
        }
    }

}

