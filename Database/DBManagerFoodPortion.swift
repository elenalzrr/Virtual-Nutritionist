import Foundation
import SQLite3

class DBManagerFoodPortion {
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
        CREATE TABLE IF NOT EXISTS food_portion(
            food_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            meal_name TEXT NOT NULL,
            date DATE NOT NULL,
            name TEXT NOT NULL,
            brand TEXT NOT NULL,
            serving_size DOUBLE NOT NULL,
            calories DOUBLE NOT NULL,
            protein DOUBLE NOT NULL,
            fats DOUBLE NOT NULL,
            carbs DOUBLE NOT NULL,
            FOREIGN KEY(user_id) REFERENCES meal(user_id)
            FOREIGN KEY(food_id) REFERENCES food(food_id)
        );
        """

        var createTableStatement: OpaquePointer? = nil

        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Food Portion table created.")
                // Commit transaction
                sqlite3_exec(db, "COMMIT", nil, nil, nil)
            } else {
                print("Food Portion table could not be created.")
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


    func insertFoodPortion(foodId: Int, userId: Int, mealName: String, date: Date, name: String, brand: String, servingSize: Double, calories: Double, protein: Double, fats: Double, carbs: Double) {
        let insertStatementString = "INSERT INTO food_portion (food_id, user_id, meal_name, date, name, brand, serving_size, calories, protein, fats, carbs) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)

        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(foodId))
            sqlite3_bind_int(insertStatement, 2, Int32(userId))
            sqlite3_bind_text(insertStatement, 3, (mealName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, (brand as NSString).utf8String, -1, nil)
            sqlite3_bind_double(insertStatement, 7, servingSize)
            sqlite3_bind_double(insertStatement, 8, calories)
            sqlite3_bind_double(insertStatement, 9, protein)
            sqlite3_bind_double(insertStatement, 10, fats)
            sqlite3_bind_double(insertStatement, 11, carbs)

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row into food_portion table.")
                // Commit transaction
                sqlite3_exec(db, "COMMIT", nil, nil, nil)
            } else {
                print("Could not insert row into food_portion table.")
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
    func isFoodPortionAlreadyExists(userId: Int, date: Date, mealName: String, name: String, brand: String) -> Bool {
        let selectStatementString = "SELECT COUNT(*) FROM food_portion WHERE user_id = ? AND date = ? AND meal_name = ? AND name = ? AND brand = ?;"
        var selectStatement: OpaquePointer? = nil
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)
        
        if sqlite3_prepare_v2(db, selectStatementString, -1, &selectStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(selectStatement, 1, Int32(userId))
            sqlite3_bind_text(selectStatement, 2, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(selectStatement, 3, (mealName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(selectStatement, 4, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(selectStatement, 5, (brand as NSString).utf8String, -1, nil)
            
            if sqlite3_step(selectStatement) == SQLITE_ROW {
                let count = sqlite3_column_int(selectStatement, 0)
                
                if count > 0 {
                    print("An entry already exists for the provided user, date, meal, name, and brand.")
                    
                    sqlite3_finalize(selectStatement)
                    return true
                }
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        
        sqlite3_finalize(selectStatement)
        return false
    }

    
    func getFoodPortions(user_id: Int, meal_name: String, date: Date) -> [(name: String, brand: String, calories: Double, serving_size: Double, fats: Double, protein: Double, carbs: Double)] {
        var foodPortions: [(name: String, brand: String, calories: Double, serving_size: Double, fats: Double, protein: Double, carbs: Double)] = []

        let selectStatementString = "SELECT name, brand, calories, serving_size, fats, protein, carbs FROM food_portion WHERE user_id = ? AND meal_name = ? AND date = ?;"
        var selectStatement: OpaquePointer? = nil

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)

        if sqlite3_prepare_v2(db, selectStatementString, -1, &selectStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(selectStatement, 1, Int32(user_id))
            sqlite3_bind_text(selectStatement, 2, (meal_name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(selectStatement, 3, (dateString as NSString).utf8String, -1, nil)

            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(selectStatement, 0))
                let brand = String(cString: sqlite3_column_text(selectStatement, 1))
                let calories = sqlite3_column_double(selectStatement, 2)
                let serving_size = sqlite3_column_double(selectStatement, 3)
                let fats = sqlite3_column_double(selectStatement, 4)
                let protein = sqlite3_column_double(selectStatement, 5)
                let carbs = sqlite3_column_double(selectStatement, 6)

                let foodPortion = (name: name, brand: brand, calories: calories, serving_size: serving_size, fats: fats, protein: protein, carbs: carbs)
                foodPortions.append(foodPortion)
            }
        } else {
            print("SELECT statement could not be prepared.")
        }

        sqlite3_finalize(selectStatement)
        return foodPortions
    }

    func getTotalCaloriesForUser(fromDate date: Date, user_id: Int) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)

        let query = "SELECT SUM(calories) FROM food_portion WHERE date = ? AND user_id = ?;"

        var totalCalories: Double = 0

        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_int(queryStatement, 2, Int32(user_id))

            if sqlite3_step(queryStatement) == SQLITE_ROW {
                totalCalories = sqlite3_column_double(queryStatement, 0)
            }
        }

        sqlite3_finalize(queryStatement)

        return totalCalories
    }
    
    func getTotalCaloriesForLast7Days(user_id: Int) -> [(String, Double)] {
        var totalCaloriesArray: [(String, Double)] = []

        let calendar = Calendar.current
        let today = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en_US")
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let totalCalories = getTotalCaloriesForUser(fromDate: date, user_id: user_id)
                let dayOfWeek = dateFormatter.string(from: date)

                totalCaloriesArray.append((dayOfWeek, totalCalories))
            }
        }

        return totalCaloriesArray
    }



    func getTotalCarbsForUser(fromDate date: Date, user_id: Int) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)

        let query = "SELECT SUM(carbs) FROM food_portion WHERE date = ? AND user_id = ?;"

        var totalCarbs: Double = 0

        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_int(queryStatement, 2, Int32(user_id))

            if sqlite3_step(queryStatement) == SQLITE_ROW {
                totalCarbs = sqlite3_column_double(queryStatement, 0)
            }
        }

        sqlite3_finalize(queryStatement)

        return totalCarbs
    }

    func getTotalProteinForUser(fromDate date: Date, user_id: Int) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)

        let query = "SELECT SUM(protein) FROM food_portion WHERE date = ? AND user_id = ?;"

        var totalProtein: Double = 0

        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_int(queryStatement, 2, Int32(user_id))

            if sqlite3_step(queryStatement) == SQLITE_ROW {
                totalProtein = sqlite3_column_double(queryStatement, 0)
            }
        }

        sqlite3_finalize(queryStatement)

        return totalProtein
    }

    func getTotalFatsForUser(fromDate date: Date, user_id: Int) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)

        let query = "SELECT SUM(fats) FROM food_portion WHERE date = ? AND user_id = ?;"

        var totalFats: Double = 0

        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_int(queryStatement, 2, Int32(user_id))

            if sqlite3_step(queryStatement) == SQLITE_ROW {
                totalFats = sqlite3_column_double(queryStatement, 0)
            }
        }

        sqlite3_finalize(queryStatement)

        return totalFats
    }

    
    func executeTransaction(_ transaction: (OpaquePointer) -> Void) {
        // Începerea tranzacției
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        // Executarea tranzacției în blocul de cod
        transaction(db!)

        // Finalizarea tranzacției
        let result = sqlite3_exec(db, "COMMIT", nil, nil, nil)
        if result != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Transaction failed to commit. Error: \(errorMessage)")

            // Anularea tranzacției în caz de eroare
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
        }
    }

    func deleteFoodPortion(forUserId userId: Int, date: Date, mealName: String, name: String) {
        let deleteStatementString = "DELETE FROM food_portion WHERE user_id = ? AND date = ? AND meal_name = ? AND name = ?;"
        var deleteStatement: OpaquePointer? = nil

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)

        executeTransaction { db in
            if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(deleteStatement, 1, Int32(userId))
                sqlite3_bind_text(deleteStatement, 2, (dateString as NSString).utf8String, -1, nil)
                sqlite3_bind_text(deleteStatement, 3, (mealName as NSString).utf8String, -1, nil)
                sqlite3_bind_text(deleteStatement, 4, (name as NSString).utf8String, -1, nil)

                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    print("Successfully deleted row from food_portion table.")
                } else {
                    print("Could not delete row from food_portion table.")
                }
            } else {
                print("DELETE statement could not be prepared.")
            }

            sqlite3_finalize(deleteStatement)
        }
    }


}
