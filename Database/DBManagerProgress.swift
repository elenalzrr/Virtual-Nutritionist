import Foundation
import SQLite3
  
class DBManagerProgress
{
    
    init()
    {
        db = openDatabase()
        createTable()
    }
    
    
    let dbPath: String = "myDb.sqlite"
    var db:OpaquePointer?
    
    
    func openDatabase() -> OpaquePointer? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let databaseURL = documentsDirectory.appendingPathComponent(dbPath)
        
        // Creează directorul de suport dacă nu există deja
        try? fileManager.createDirectory(at: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
        
        var db: OpaquePointer? = nil
        if sqlite3_open(databaseURL.path, &db) != SQLITE_OK {
            debugPrint("Can't open database")
            return nil
        } else {
            // print("Successfully opened connection to database at \(databaseURL.path)")
            return db
        }
    }

    
    func createTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS progress(
            user_id INTEGER NOT NULL,
            date DATE NOT NULL,
            weight REAL NOT NULL,
            FOREIGN KEY(user_id) REFERENCES user(user_id)
        );
        """
        
        executeTransaction { db in
            var createTableStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
                if sqlite3_step(createTableStatement) == SQLITE_DONE {
                    //print("progress table created.")
                } else {
                    print("progress table could not be created.")
                }
            } else {
                print("CREATE TABLE statement could not be prepared.")
            }
            
            sqlite3_finalize(createTableStatement)
        }
    }
    
    func insertProgress(user_id: Int, date: Date, weight: Double) {
        let insertStatementString = "INSERT INTO progress (user_id, date, weight) VALUES (?, ?, ?);"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)
        
        executeTransaction { db in
            var insertStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(insertStatement, 1, Int32(user_id))
                sqlite3_bind_text(insertStatement, 2, (dateString as NSString).utf8String, -1, nil)
                sqlite3_bind_double(insertStatement, 3, weight)
                
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Successfully inserted row into progress table.")
                } else {
                    print("Could not insert row into progress table.")
                }
            } else {
                print("INSERT statement could not be prepared for progress table.")
            }
            
            sqlite3_finalize(insertStatement)
        }
    }
    private var transactionLevel: Int = 0

    private func executeTransaction(_ closure: (OpaquePointer) -> Void) {
        guard let db = db else {
            print("Database connection is not available.")
            return
        }

        if transactionLevel > 0 {
            // Există deja o tranzacție în desfășurare, doar execută blocul de cod
            closure(db)
            return
        }

        // Începe tranzacția
        if sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil) != SQLITE_OK {
            print("Failed to begin transaction.")
            return
        }

        // Mărește nivelul tranzacțiilor
        transactionLevel += 1

        // Execută blocul de cod
        closure(db)

        // Scade nivelul tranzacțiilor
        transactionLevel -= 1

        // Verifică dacă nivelul tranzacțiilor a revenit la 0 și încheie tranzacția
        if transactionLevel == 0 {
            if sqlite3_exec(db, "COMMIT", nil, nil, nil) != SQLITE_OK {
                print("Failed to commit transaction.")
                return
            }
        }
    }


    func getWeightsForUser(user_id: Int) -> [(Double, Date)] {
        let queryStatementString = "SELECT weight, date FROM progress WHERE user_id = ? ORDER BY date ASC;"
        var queryStatement: OpaquePointer? = nil
        var weights: [(Double, Date)] = []
        
        executeTransaction { db in
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(queryStatement, 1, Int32(user_id))
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let weight = sqlite3_column_double(queryStatement, 0)
                    let dateString = String(cString: sqlite3_column_text(queryStatement, 1))
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    if let date = dateFormatter.date(from: dateString) {
                        weights.append((weight, date))
                    }
                }
            } else {
                print("SELECT statement could not be prepared")
            }
            
            weights.sort(by: { $0.1 < $1.1 })
            sqlite3_finalize(queryStatement)
        }
        
        return weights
    }
    
    func deleteProgressByUserIdAndDate(user_id: Int, date: Date) {
        let deleteStatementString = "DELETE FROM progress WHERE user_id = ? AND date = ?;"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)
        
        executeTransaction { db in
            var deleteStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(deleteStatement, 1, Int32(user_id))
                sqlite3_bind_text(deleteStatement, 2, (dateString as NSString).utf8String, -1, nil)
                
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    print("Deleted progress for user_id \(user_id) and date \(dateString)")
                } else {
                    print("Could not delete progress for user_id \(user_id) and date \(dateString)")
                }
            } else {
                print("DELETE statement could not be prepared")
            }
            
            sqlite3_finalize(deleteStatement)
        }
    }
    func updateProgressByUserIdAndDate(user_id: Int, date: Date, weight: Double) {
        let updateStatementString = "UPDATE progress SET weight = ? WHERE user_id = ? AND date = ?;"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)
        
        executeTransaction { db in
            var updateStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
                sqlite3_bind_double(updateStatement, 1, weight)
                sqlite3_bind_int(updateStatement, 2, Int32(user_id))
                sqlite3_bind_text(updateStatement, 3, (dateString as NSString).utf8String, -1, nil)
                
                if sqlite3_step(updateStatement) == SQLITE_DONE {
                    print("Updated progress for user_id \(user_id) and date \(dateString)")
                } else {
                    print("Could not update progress for user_id \(user_id) and date \(dateString)")
                }
            } else {
                print("UPDATE statement could not be prepared")
            }
            
            sqlite3_finalize(updateStatement)
        }
    }
        
        
        func insertOrUpdateProgress(user_id: Int, date: Date, weight: Double) {
            let queryStatementString = "SELECT COUNT(*) FROM progress WHERE user_id = ? AND date = ?;"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: date)
            
            executeTransaction { db in
                var queryStatement: OpaquePointer? = nil
                var entryCount: Int = 0
                
                if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                    sqlite3_bind_int(queryStatement, 1, Int32(user_id))
                    sqlite3_bind_text(queryStatement, 2, (dateString as NSString).utf8String, -1, nil)
                    
                    if sqlite3_step(queryStatement) == SQLITE_ROW {
                        entryCount = Int(sqlite3_column_int(queryStatement, 0))
                    }
                }
                
                sqlite3_finalize(queryStatement)
                
                if entryCount > 0 {
                    updateProgressByUserIdAndDate(user_id: user_id, date: date, weight: weight)
                } else {
                    insertProgress(user_id: user_id, date: date, weight: weight)
                }
            }
        }
    
        func getEntryCountForUser(user_id: Int) -> Int {
            let queryStatementString = "SELECT COUNT(*) FROM progress WHERE user_id = ?;"
            var queryStatement: OpaquePointer? = nil
            var entryCount: Int = 0
            
            executeTransaction { db in
                if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                    sqlite3_bind_int(queryStatement, 1, Int32(user_id))
                    
                    if sqlite3_step(queryStatement) == SQLITE_ROW {
                        entryCount = Int(sqlite3_column_int(queryStatement, 0))
                    }
                } else {
                    print("SELECT statement could not be prepared")
                }
                
                sqlite3_finalize(queryStatement)
            }
            
            return entryCount
        }
        
        
        
    }
    

