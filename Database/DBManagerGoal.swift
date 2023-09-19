import Foundation
import SQLite3

class DBManagerGoal {
    
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

    
    func createTable() {
        executeTransaction { db in
            let createTableString = """
            CREATE TABLE IF NOT EXISTS goal(
                user_id INTEGER NOT NULL,
                calories DOUBLE NOT NULL,
                protein DOUBLE NOT NULL,
                fats DOUBLE NOT NULL,
                carbs DOUBLE NOT NULL,
                weight DOUBLE NOT NULL,
                date DATE NOT NULL,
                FOREIGN KEY(user_id) REFERENCES user(user_id)
            );
            """
            
            var createTableStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
                if sqlite3_step(createTableStatement) == SQLITE_DONE {
                    //   print("goal table created.")
                } else {
                    //  print("goal table could not be created.")
                }
            } else {
                //  print("CREATE TABLE statement could not be prepared.")
            }
            sqlite3_finalize(createTableStatement)
        }
    }

    func insert(user_id: Int, calories: Double, protein: Double, fats: Double, carbs: Double, weight: Double, date: Date) {
        executeTransaction { db in
            let insertStatementString = "INSERT INTO goal (user_id, calories, protein, fats, carbs, weight, date) VALUES (?, ?, ?, ?, ?, ?, ?);"
            var insertStatement: OpaquePointer? = nil
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            let dateString = dateFormatter.string(from: date)
            
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(insertStatement, 1, Int32(user_id))
                sqlite3_bind_double(insertStatement, 2, calories)
                sqlite3_bind_double(insertStatement, 3, protein)
                sqlite3_bind_double(insertStatement, 4, fats)
                sqlite3_bind_double(insertStatement, 5, carbs)
                sqlite3_bind_double(insertStatement, 6, weight)
                sqlite3_bind_text(insertStatement, 7, (dateString as NSString).utf8String, -1, nil)
                
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Successfully inserted row into goal table.")
                } else {
                    print("Could not insert row into goal table.")
                }
            } else {
                print("INSERT statement could not be prepared for goal table.")
            }
            
            sqlite3_finalize(insertStatement)
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
    
    func getCalories(forUserId userId: Int, date: Date) -> Double? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: date)

        var calories: Double?
        executeTransaction { db in
            let queryStatementString = "SELECT calories FROM goal WHERE user_id = ? AND date <= ? ORDER BY date DESC LIMIT 1;"
            var queryStatement: OpaquePointer? = nil

            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(queryStatement, 1, Int32(userId))
                sqlite3_bind_text(queryStatement, 2, (dateString as NSString).utf8String, -1, nil)

                if sqlite3_step(queryStatement) == SQLITE_ROW {
                    calories = sqlite3_column_double(queryStatement, 0)
                }
            } else {
                print("SELECT statement could not be prepared.")
            }

            sqlite3_finalize(queryStatement)
        }

        if let calories = calories {
            return calories
        } else {
            // Nu există date pentru data respectivă sau user_id-ul dat
            // Încercați să obțineți cel mai apropiat set de date înainte de data respectivă
            executeTransaction { db in
                let queryStatementString = "SELECT calories FROM goal WHERE user_id = ? AND date <= ? ORDER BY date DESC LIMIT 1;"
                var queryStatement: OpaquePointer? = nil

                if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                    sqlite3_bind_int(queryStatement, 1, Int32(userId))
                    sqlite3_bind_text(queryStatement, 2, (dateString as NSString).utf8String, -1, nil)

                    if sqlite3_step(queryStatement) == SQLITE_ROW {
                        calories = sqlite3_column_double(queryStatement, 0)
                    }
                } else {
                    print("SELECT statement could not be prepared.")
                }

                sqlite3_finalize(queryStatement)
            }
            
            if let calories = calories {
                return calories
            } else {
                // Nu există date pentru data respectivă sau user_id-ul dat
                // Încercați să obțineți cel mai apropiat set de date după data respectivă
                executeTransaction { db in
                    let queryStatementString = "SELECT calories FROM goal WHERE user_id = ? AND date > ? ORDER BY date ASC LIMIT 1;"
                    var queryStatement: OpaquePointer? = nil

                    if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                        sqlite3_bind_int(queryStatement, 1, Int32(userId))
                        sqlite3_bind_text(queryStatement, 2, (dateString as NSString).utf8String, -1, nil)

                        if sqlite3_step(queryStatement) == SQLITE_ROW {
                            calories = sqlite3_column_double(queryStatement, 0)
                        }
                    } else {
                        print("SELECT statement could not be prepared.")
                    }

                    sqlite3_finalize(queryStatement)
                }
                
                if let calories = calories {
                    return calories
                } else {
                    // Nu există date pentru data respectivă sau user_id-ul dat
                    return nil
                }
            }
        }
    }

    
    func updateLastWeightForUser(userID: Int, newWeight: Double) {
        executeTransaction { db in
            let updateStatementString = """
                UPDATE goal
                SET weight = ?
                WHERE user_id = ?
                ORDER BY date DESC LIMIT 1;
                """
            
            var updateStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
                sqlite3_bind_double(updateStatement, 1, newWeight)
                sqlite3_bind_int(updateStatement, 2, Int32(userID))
                sqlite3_bind_int(updateStatement, 3, Int32(userID))
                
                if sqlite3_step(updateStatement) == SQLITE_DONE {
                    print("Successfully updated last weight for user with ID \(userID).")
                } else {
                    print("Could not update last weight for user with ID \(userID).")
                }
            } else {
                print("UPDATE statement could not be prepared.")
            }
            
            sqlite3_finalize(updateStatement)
        }
    }

    func getLatestWeightForUser(userID: Int) -> Double? {
        var latestWeight: Double? = nil
        
        executeTransaction { db in
            let selectStatementString = "SELECT weight FROM goal WHERE user_id = ? ORDER BY date DESC LIMIT 1;"
            var selectStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, selectStatementString, -1, &selectStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(selectStatement, 1, Int32(userID))
                
                if sqlite3_step(selectStatement) == SQLITE_ROW {
                    latestWeight = sqlite3_column_double(selectStatement, 0)
                }
            }
            
            sqlite3_finalize(selectStatement)
        }
        
        return latestWeight
    }
    func getLatestProteinForUser(userID: Int) -> Double? {
        var latestProtein: Double? = nil
        
        executeTransaction { db in
            let selectStatementString = "SELECT protein FROM goal WHERE user_id = ? ORDER BY date DESC LIMIT 1;"
            var selectStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, selectStatementString, -1, &selectStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(selectStatement, 1, Int32(userID))
                
                if sqlite3_step(selectStatement) == SQLITE_ROW {
                    latestProtein = sqlite3_column_double(selectStatement, 0)
                }
            }
            
            sqlite3_finalize(selectStatement)
        }
        
        return latestProtein
    }

    func getLatestCarbsForUser(userID: Int) -> Double? {
        var latestCarbs: Double? = nil
        
        executeTransaction { db in
            let selectStatementString = "SELECT carbs FROM goal WHERE user_id = ? ORDER BY date DESC LIMIT 1;"
            var selectStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, selectStatementString, -1, &selectStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(selectStatement, 1, Int32(userID))
                
                if sqlite3_step(selectStatement) == SQLITE_ROW {
                    latestCarbs = sqlite3_column_double(selectStatement, 0)
                }
            }
            
            sqlite3_finalize(selectStatement)
        }
        
        return latestCarbs
    }
    func getLatestFatsForUser(userID: Int) -> Double? {
        var latestFats: Double? = nil
        
        executeTransaction { db in
            let selectStatementString = "SELECT fats FROM goal WHERE user_id = ? ORDER BY date DESC LIMIT 1;"
            var selectStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, selectStatementString, -1, &selectStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(selectStatement, 1, Int32(userID))
                
                if sqlite3_step(selectStatement) == SQLITE_ROW {
                    latestFats = sqlite3_column_double(selectStatement, 0)
                }
            }
            
            sqlite3_finalize(selectStatement)
        }
        
        return latestFats
    }

    func getLatestCaloriesForUser(userID: Int) -> Double? {
        var latestCalories: Double? = nil
        
        executeTransaction { db in
            let selectStatementString = "SELECT calories FROM goal WHERE user_id = ? ORDER BY date DESC LIMIT 1;"
            var selectStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, selectStatementString, -1, &selectStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(selectStatement, 1, Int32(userID))
                
                if sqlite3_step(selectStatement) == SQLITE_ROW {
                    latestCalories = sqlite3_column_double(selectStatement, 0)
                }
            }
            
            sqlite3_finalize(selectStatement)
        }
        
        return latestCalories
    }



}
