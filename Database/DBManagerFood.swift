import Foundation
import SQLite3

class DBManagerFood {
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
        CREATE TABLE IF NOT EXISTS food(
            food_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            brand TEXT NOT NULL,
            serving_size DOUBLE NOT NULL,
            unit TEXT NOT NULL,
            calories DOUBLE NOT NULL,
            protein DOUBLE NOT NULL,
            fats DOUBLE NOT NULL,
            carbs DOUBLE NOT NULL,
            bar_code TEXT,
            is_visible BOOLEAN NOT NULL,
            created_by TEXT NOT NULL,
            date DATE NOT NULL,
            review BOOLEAN NOT NULL
        );
        """
        
        var createTableStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
              //  print("Food table created.")
                // Commit transaction
                sqlite3_exec(db, "COMMIT", nil, nil, nil)
            } else {
                print("Food table could not be created.")
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
    func insert(name: String, brand: String, servingSize: Double, unit: String, calories: Double, protein: Double, fats: Double, carbs: Double, barcode: String, isVisible: Bool, createdBy: String, date: Date, review: Bool) {
        let insertStatementString = "INSERT INTO food (name, brand, serving_size, unit, calories, protein, fats, carbs, bar_code, is_visible, created_by, date, review) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil

        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (brand as NSString).utf8String, -1, nil)
            sqlite3_bind_double(insertStatement, 3, servingSize)
            sqlite3_bind_text(insertStatement, 4, (unit as NSString).utf8String, -1, nil)
            sqlite3_bind_double(insertStatement, 5, calories)
            sqlite3_bind_double(insertStatement, 6, protein)
            sqlite3_bind_double(insertStatement, 7, fats)
            sqlite3_bind_double(insertStatement, 8, carbs)
            sqlite3_bind_text(insertStatement, 9, (barcode as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 10, isVisible ? 1 : 0)
            sqlite3_bind_text(insertStatement, 11, (createdBy as NSString).utf8String, -1, nil)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yy HH:mm"
            let dateString = dateFormatter.string(from: date)
            sqlite3_bind_text(insertStatement, 12, (dateString as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int(insertStatement, 13, review ? 1 : 0)

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row into food table.")
                // Commit transaction
                sqlite3_exec(db, "COMMIT", nil, nil, nil)
            } else {
                print("Could not insert row into food table.")
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

    func updateFood(for foodId: Int, name: String, brand: String, servingSize: Double, unit: String, calories: Double, protein: Double, fats: Double, carbs: Double, barcode: String, isVisible: Bool, review: Bool) {
        let updateStatementString = """
            UPDATE food SET
            name = ?,
            brand = ?,
            serving_size = ?,
            unit = ?,
            calories = ?,
            protein = ?,
            fats = ?,
            carbs = ?,
            bar_code = ?,
            is_visible = ?,
            review = ?
            WHERE food_id = ?;
            """
        var updateStatement: OpaquePointer? = nil

        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (brand as NSString).utf8String, -1, nil)
            sqlite3_bind_double(updateStatement, 3, servingSize)
            sqlite3_bind_text(updateStatement, 4, (unit as NSString).utf8String, -1, nil)
            sqlite3_bind_double(updateStatement, 5, calories)
            sqlite3_bind_double(updateStatement, 6, protein)
            sqlite3_bind_double(updateStatement, 7, fats)
            sqlite3_bind_double(updateStatement, 8, carbs)
            sqlite3_bind_text(updateStatement, 9, (barcode as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 10, isVisible ? 1 : 0)
            sqlite3_bind_int(updateStatement, 11, review ? 1 : 0)
            sqlite3_bind_int(updateStatement, 12, Int32(foodId))

            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated food with food_id \(foodId).")
                // Commit transaction
                sqlite3_exec(db, "COMMIT", nil, nil, nil)
            } else {
                print("Could not update food with food_id \(foodId).")
                // Rollback transaction
                sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
            }
        } else {
            print("UPDATE statement could not be prepared.")
            // Rollback transaction
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
        }

        sqlite3_finalize(updateStatement)
    }

    func getFoodData(createdBy: String) -> [(String, String, Double, Double, Double, Double, Double)]? {
        var queryStatementString = "SELECT name, brand, serving_size, calories, protein, fats, carbs FROM food WHERE created_by = ?"
        
        var queryStatement: OpaquePointer? = nil
        var foodData = [(String, String, Double, Double, Double, Double, Double)]()

        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // Bind createdBy parameter
            sqlite3_bind_text(queryStatement, 1, (createdBy as NSString).utf8String, -1, nil)
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(queryStatement, 0))
                let brand = String(cString: sqlite3_column_text(queryStatement, 1))
                let servingSize = sqlite3_column_double(queryStatement, 2)
                let calories = sqlite3_column_double(queryStatement, 3)
                let protein = sqlite3_column_double(queryStatement, 4)
                let fats = sqlite3_column_double(queryStatement, 5)
                let carbs = sqlite3_column_double(queryStatement, 6)

                let food = (name, brand, servingSize, calories, protein, fats, carbs)
                foodData.append(food)
            }
            
            // Release queryStatement
            sqlite3_finalize(queryStatement)
            
            // Query for additional records where is_visible = true and exclude the ones already found
            queryStatementString = "SELECT name, brand, serving_size, calories, protein, fats, carbs FROM food WHERE is_visible = 1 AND created_by != ?"
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                // Bind createdBy parameter
                sqlite3_bind_text(queryStatement, 1, (createdBy as NSString).utf8String, -1, nil)
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let name = String(cString: sqlite3_column_text(queryStatement, 0))
                    let brand = String(cString: sqlite3_column_text(queryStatement, 1))
                    let servingSize = sqlite3_column_double(queryStatement, 2)
                    let calories = sqlite3_column_double(queryStatement, 3)
                    let protein = sqlite3_column_double(queryStatement, 4)
                    let fats = sqlite3_column_double(queryStatement, 5)
                    let carbs = sqlite3_column_double(queryStatement, 6)

                    let food = (name, brand, servingSize, calories, protein, fats, carbs)
                    // Check if the food is already included in foodData
                    if !foodData.contains(where: { $0.0 == name && $0.1 == brand }) {
                        foodData.append(food)
                    }
                }
            } else {
                print("SELECT statement could not be prepared for food table.")
                // Rollback transaction
                sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
                return nil
            }
            
            // Commit transaction
            sqlite3_exec(db, "COMMIT", nil, nil, nil)
        } else {
            print("SELECT statement could not be prepared for food table.")
            // Rollback transaction
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
            return nil
        }

        sqlite3_finalize(queryStatement)
        return foodData
    }

    func getFoodDataForId(for foodId: Int) -> (String, String, Double, Double, Double, Double, Double)? {
        let queryStatementString = "SELECT name, brand, serving_size, calories, protein, fats, carbs FROM food WHERE food_id = ?;"
        var queryStatement: OpaquePointer? = nil
        var food: (String, String, Double, Double, Double, Double, Double)? = nil

        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // Bind foodId to the prepared statement
            sqlite3_bind_int(queryStatement, 1, Int32(foodId))

            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(queryStatement, 0))
                let brand = String(cString: sqlite3_column_text(queryStatement, 1))
                let servingSize = sqlite3_column_double(queryStatement, 2)
                let calories = sqlite3_column_double(queryStatement, 3)
                let protein = sqlite3_column_double(queryStatement, 4)
                let fats = sqlite3_column_double(queryStatement, 5)
                let carbs = sqlite3_column_double(queryStatement, 6)

                food = (name, brand, servingSize, calories, protein, fats, carbs)
            }

            // Commit transaction
            sqlite3_exec(db, "COMMIT", nil, nil, nil)
        } else {
            print("SELECT statement could not be prepared for food table.")
            // Rollback transaction
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
            return nil
        }

        sqlite3_finalize(queryStatement)
        return food
    }
    func getFoodForId(for foodId: Int) -> (String, String, Double, Double, Double, Double, Double, String, String)? {
        let queryStatementString = "SELECT name, brand, serving_size, calories, protein, fats, carbs, bar_code, unit FROM food WHERE food_id = ?;"
        var queryStatement: OpaquePointer? = nil
        var food: (String, String, Double, Double, Double, Double, Double, String, String)? = nil

        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // Bind foodId to the prepared statement
            sqlite3_bind_int(queryStatement, 1, Int32(foodId))

            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(queryStatement, 0))
                let brand = String(cString: sqlite3_column_text(queryStatement, 1))
                let servingSize = sqlite3_column_double(queryStatement, 2)
                let calories = sqlite3_column_double(queryStatement, 3)
                let protein = sqlite3_column_double(queryStatement, 4)
                let fats = sqlite3_column_double(queryStatement, 5)
                let carbs = sqlite3_column_double(queryStatement, 6)
                let barcode = String(cString: sqlite3_column_text(queryStatement, 7))
                let unit = String(cString: sqlite3_column_text(queryStatement, 8))

                food = (name, brand, servingSize, calories, protein, fats, carbs, barcode, unit)
            }

            // Commit transaction
            sqlite3_exec(db, "COMMIT", nil, nil, nil)
        } else {
            print("SELECT statement could not be prepared for food table.")
            // Rollback transaction
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
            return nil
        }

        sqlite3_finalize(queryStatement)
        return food
    }

    func getFoodId(forData data: (String, String, Double, Double, Double, Double, Double)) -> Int? {
        let queryStatementString = """
            SELECT food_id FROM food WHERE
            name = ? AND brand = ? AND serving_size = ? AND
            calories = ? AND protein = ? AND fats = ? AND
            carbs = ?;
        """
        var queryStatement: OpaquePointer? = nil
        var foodId: Int? = nil

        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (data.0 as NSString).utf8String, -1, nil)
            sqlite3_bind_text(queryStatement, 2, (data.1 as NSString).utf8String, -1, nil)
            sqlite3_bind_double(queryStatement, 3, data.2)
            sqlite3_bind_double(queryStatement, 4, data.3)
            sqlite3_bind_double(queryStatement, 5, data.4)
            sqlite3_bind_double(queryStatement, 6, data.5)
            sqlite3_bind_double(queryStatement, 7, data.6)

            if sqlite3_step(queryStatement) == SQLITE_ROW {
                foodId = Int(sqlite3_column_int(queryStatement, 0))
            }

            // Commit transaction
            sqlite3_exec(db, "COMMIT", nil, nil, nil)
        } else {
            print("SELECT statement could not be prepared for food table.")
            // Rollback transaction
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
        }

        sqlite3_finalize(queryStatement)
        return foodId
    }
    
    func getUnitByNameAndBrand(name: String, brand: String) -> String? {
        let queryStatementString = """
            SELECT unit FROM food WHERE
            name = ? AND brand = ? ;
        """
        var queryStatement: OpaquePointer? = nil
        var unit: String? = nil

        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(queryStatement, 2, (brand as NSString).utf8String, -1, nil)

            if sqlite3_step(queryStatement) == SQLITE_ROW {
                unit = String(cString: sqlite3_column_text(queryStatement, 0))
            }

            // Commit transaction
            sqlite3_exec(db, "COMMIT", nil, nil, nil)
        } else {
            print("SELECT statement could not be prepared for food table.")
            // Rollback transaction
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
        }

        sqlite3_finalize(queryStatement)
        return unit
    }

    
    func getFoodIdByName(name: String, brand: String) -> Int? {
        let queryStatementString = """
            SELECT food_id FROM food WHERE
            name = ? AND brand = ? ;
        """
        var queryStatement: OpaquePointer? = nil
        var foodId: Int? = nil

        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(queryStatement, 2, (brand as NSString).utf8String, -1, nil)

            if sqlite3_step(queryStatement) == SQLITE_ROW {
                foodId = Int(sqlite3_column_int(queryStatement, 0))
            }

            // Commit transaction
            sqlite3_exec(db, "COMMIT", nil, nil, nil)
        } else {
            print("SELECT statement could not be prepared for food table.")
            // Rollback transaction
            sqlite3_exec(db, "ROLLBACK", nil, nil,nil)
        }

        sqlite3_finalize(queryStatement)
        return foodId
    }
    
    func getFoodIdByNameAndCreatedBy(name: String, brand: String, createdBy: String) -> Int? {
        let queryStatementString = """
            SELECT food_id FROM food WHERE
            name = ? AND brand = ? AND created_by = ?;
        """
        var queryStatement: OpaquePointer? = nil
        var foodId: Int? = nil

        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(queryStatement, 2, (brand as NSString).utf8String, -1, nil)
            sqlite3_bind_text(queryStatement, 3, (createdBy as NSString).utf8String, -1, nil)

            if sqlite3_step(queryStatement) == SQLITE_ROW {
                foodId = Int(sqlite3_column_int(queryStatement, 0))
            }

            // Commit transaction
            sqlite3_exec(db, "COMMIT", nil, nil, nil)
        } else {
            print("SELECT statement could not be prepared for food table.")
            // Rollback transaction
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
        }

        sqlite3_finalize(queryStatement)
        return foodId
    }


    func getFoodIdByBarcode(barcode: String) -> Int? {
        let queryStatementString = "SELECT food_id FROM food WHERE bar_code = ?;"
        var queryStatement: OpaquePointer? = nil
        var foodId: Int? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (barcode as NSString).utf8String, -1, nil)
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                foodId = Int(sqlite3_column_int(queryStatement, 0))
            }
            
            // Commit transaction
            sqlite3_exec(db, "COMMIT", nil, nil, nil)
        } else {
            print("SELECT statement could not be prepared for food table.")
            // Rollback transaction
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
        }
        
        sqlite3_finalize(queryStatement)
        return foodId
    }
    
    func checkBarcodeExists(barcode: String) -> Bool {
        if barcode.isEmpty {
            return false
        }
        
        let queryStatementString = "SELECT COUNT(*) FROM food WHERE bar_code = ?;"
        var queryStatement: OpaquePointer? = nil
        var barcodeCount = 0
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (barcode as NSString).utf8String, -1, nil)
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                barcodeCount = Int(sqlite3_column_int(queryStatement, 0))
            }
            
            // Commit transaction
            sqlite3_exec(db, "COMMIT", nil, nil, nil)
        } else {
            print("SELECT statement could not be prepared for food table.")
            // Rollback transaction
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
        }
        
        sqlite3_finalize(queryStatement)
        return barcodeCount > 0
    }

    func news() -> [(String, String, String)] {
        var entries: [(String, String, String)] = []
        
        let query = """
        SELECT created_by, name, brand
        FROM food
        WHERE review = 0 AND created_by <> 'admin'
        ORDER BY date DESC
        LIMIT 15
        """
        
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                if let createdBy = sqlite3_column_text(queryStatement, 0),
                   let name = sqlite3_column_text(queryStatement, 1),
                   let brand = sqlite3_column_text(queryStatement, 2) {
                    let createdByString = String(cString: createdBy)
                    let nameString = String(cString: name)
                    let brandString = String(cString: brand)
                    let entry = (createdByString, nameString, brandString)
                    entries.append(entry)
                }
            }
        } else {
            print("Failed to execute the query.")
        }
        
        sqlite3_finalize(queryStatement)
        
        return entries
    }
    
    func approved() -> [(String, String, String)] {
        var entries: [(String, String, String)] = []
        
        let query = "SELECT name, brand, created_by FROM food WHERE review = 1 AND is_visible = 1;"
        
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(queryStatement, 0))
                let brand = String(cString: sqlite3_column_text(queryStatement, 1))
                let createdBy = String(cString: sqlite3_column_text(queryStatement, 2))
                
                entries.append((name, brand, createdBy))
            }
        }
        
        sqlite3_finalize(queryStatement)
        
        return entries
    }

    
    func pending() -> [(String, String, String)] {
        var entries: [(String, String, String)] = []
        
        let query = "SELECT name, brand, created_by FROM food WHERE review = 0;"
        
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(queryStatement, 0))
                let brand = String(cString: sqlite3_column_text(queryStatement, 1))
                let createdBy = String(cString: sqlite3_column_text(queryStatement, 2))
                
                entries.append((name, brand, createdBy))
            }
        }
        
        sqlite3_finalize(queryStatement)
        
        return entries
    }
    





}
