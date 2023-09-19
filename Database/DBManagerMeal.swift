import Foundation
import SQLite3


class DBManagerMeal {
    init() {
        db = openDatabase()
        createTable()
    }

    let dbPath: String = "myDb.sqlite"
    var db: OpaquePointer?

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
        CREATE TABLE IF NOT EXISTS meal(
            user_id INTEGER NOT NULL,
            date DATE NOT NULL,
            name TEXT NOT NULL,
            inUse BOOLEAN NOT NULL,
            FOREIGN KEY(user_id) REFERENCES user(user_id)
        );
        """

        var createTableStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
            //    print("Meal table created.")
                // Commit transaction
                sqlite3_exec(db, "COMMIT", nil, nil, nil)
            } else {
                print("Meal table could not be created.")
                // Rollback transaction
                sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
            // Rollback transaction
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
        }
        
        sqlite3_finalize(createTableStatement)
    }


    func insert(user_id: Int, date: Date, name: String, inUse: Bool) {
        let insertStatementString = "INSERT INTO meal (user_id, date, name, inUse) VALUES (?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: date)

        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(user_id))
            sqlite3_bind_text(insertStatement, 2, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 4, inUse ? 1 : 0)

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row into meal table.")
                // Commit transaction
                sqlite3_exec(db, "COMMIT", nil, nil, nil)
            } else {
                print("Could not insert row into meal table.")
                // Rollback transaction
                sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
            }
        } else {
            print("INSERT statement could not be prepared.")
            // Rollback transaction
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
        }

        sqlite3_finalize(insertStatement)
    }

    func getNamesForUser(user_id: Int) -> [String] {
        let selectStatementString = "SELECT name FROM meal WHERE user_id = ? AND inUse = 1;"
        var selectStatement: OpaquePointer? = nil
        var names: [String] = []

        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        if sqlite3_prepare_v2(db, selectStatementString, -1, &selectStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(selectStatement, 1, Int32(user_id))

            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(selectStatement, 0))
                names.append(name)
            }
        } else {
            print("SELECT statement could not be prepared.")
        }

        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)

        sqlite3_finalize(selectStatement)
        return names
    }



}
