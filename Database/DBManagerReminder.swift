import Foundation
import SQLite3

class DBManagerReminder {
    
    init() {
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

    
    func executeTransaction(_ block: (OpaquePointer) -> Void) {
        guard let db = db else {
            print("Database connection is not available.")
            return
        }
        
        var shouldCommit = false
        
        if sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil) == SQLITE_OK {
            block(db)
            shouldCommit = true
        } else {
            print("Failed to begin transaction.")
        }
        
        if shouldCommit {
            if sqlite3_exec(db, "COMMIT", nil, nil, nil) != SQLITE_OK {
                print("Failed to commit transaction.")
            }
        } else {
            if sqlite3_exec(db, "ROLLBACK", nil, nil, nil) != SQLITE_OK {
                print("Failed to rollback transaction.")
            }
        }
    }
    func createTable() {
        executeTransaction { db in
            let createTableString = """
            CREATE TABLE IF NOT EXISTS reminder(
                user_id INTEGER NOT NULL,
                name TEXT NOT NULL,
                date DATE NOT NULL,
                isActive BOOLEAN NOT NULL,
                FOREIGN KEY(user_id) REFERENCES user(user_id)
            );
            """
            
            var createTableStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
                if sqlite3_step(createTableStatement) == SQLITE_DONE {
                    print("reminder table created.")
                } else {
                    print("reminder table could not be created.")
                }
            } else {
                print("CREATE TABLE statement could not be prepared.")
            }
            
            sqlite3_finalize(createTableStatement)
        }
    }

    func checkReminderExists(forUserId userId: Int, date: Date) -> Bool {
        var reminderExists = false
        
        executeTransaction { db in
            let queryStatementString = "SELECT COUNT(*) FROM reminder WHERE user_id = ? AND date = ?;"
            var queryStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(queryStatement, 1, Int32(userId))
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let dateString = dateFormatter.string(from: date)
                sqlite3_bind_text(queryStatement, 2, (dateString as NSString).utf8String, -1, nil)
                
                if sqlite3_step(queryStatement) == SQLITE_ROW {
                    let count = sqlite3_column_int(queryStatement, 0)
                    if count > 0 {
                        reminderExists = true
                    }
                }
            }
            
            sqlite3_finalize(queryStatement)
        }
        
        return reminderExists
    }
    func insertReminder(user_id: Int, name: String, date: Date, isActive: Bool) {
        executeTransaction { db in
            let insertStatementString = "INSERT INTO reminder (user_id, name, date, isActive) VALUES (?, ?, ?, ?);"
            var insertStatement: OpaquePointer? = nil

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let dateString = dateFormatter.string(from: date)

            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(insertStatement, 1, Int32(user_id))
                sqlite3_bind_text(insertStatement, 2, (name as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 3, (dateString as NSString).utf8String, -1, nil)
                sqlite3_bind_int(insertStatement, 4, isActive ? 1 : 0)

                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Successfully inserted row into reminder table.")
                } else {
                    print("Could not insert row into reminder table.")
                }
            } else {
                print("INSERT statement could not be prepared for reminder table.")
            }

            sqlite3_finalize(insertStatement)
        }
    }

    func getReminders(forUserId userId: Int) -> [(String, Date, Bool)]? {
        var reminders: [(String, Date, Bool)]?

        executeTransaction { db in
            let queryStatementString = "SELECT name, date, isActive FROM reminder WHERE user_id = ?;"
            var queryStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(queryStatement, 1, Int32(userId))
                
                reminders = []
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let name = String(cString: sqlite3_column_text(queryStatement, 0))
                    let dateString = String(cString: sqlite3_column_text(queryStatement, 1))
                    let isActive = sqlite3_column_int(queryStatement, 2) == 1
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    if let date = dateFormatter.date(from: dateString) {
                        let reminder = (name, date, isActive)
                        reminders?.append(reminder)
                    }
                }
            } else {
                print("SELECT statement could not be prepared")
                reminders = nil
            }
            
            sqlite3_finalize(queryStatement)
        }
        
        return reminders
    }
    func updateReminderIsActive(forUserId userId: Int, date: Date, isActive: Bool) {
        executeTransaction { db in
            let updateStatementString = "UPDATE reminder SET isActive = ? WHERE user_id = ? AND date = ?;"

            var updateStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(updateStatement, 1, isActive ? 1 : 0)
                sqlite3_bind_int(updateStatement, 2, Int32(userId))

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let dateString = dateFormatter.string(from: date)
                sqlite3_bind_text(updateStatement, 3, (dateString as NSString).utf8String, -1, nil)

                if sqlite3_step(updateStatement) == SQLITE_DONE {
                    print("Successfully updated isActive in reminder table.")
                } else {
                    print("Could not update isActive in reminder table.")
                }
            } else {
                print("UPDATE statement could not be prepared for reminder table.")
            }

            sqlite3_finalize(updateStatement)
        }
    }

    func deleteReminders(fromDate date: Date, forUserId userId: Int) {
        executeTransaction { db in
            let deleteStatementString = "DELETE FROM reminder WHERE date = ? AND user_id = ?;"

            var deleteStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let dateString = dateFormatter.string(from: date)
                sqlite3_bind_text(deleteStatement, 1, (dateString as NSString).utf8String, -1, nil)
                sqlite3_bind_int(deleteStatement, 2, Int32(userId))

                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    print("Successfully deleted reminders.")
                } else {
                    print("Could not delete reminders.")
                }
            } else {
                print("DELETE statement could not be prepared for reminders.")
            }

            sqlite3_finalize(deleteStatement)
        }
    }


}
