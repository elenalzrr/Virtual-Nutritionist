import Foundation
import UIKit
import SQLite3
import CryptoKit
  
class DBManagerUser
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
             print("Successfully opened connection to database at \(databaseURL.path)")
            return db
        }
    }

    
    
    func createTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS user(
            user_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            username TEXT NOT NULL,
            email TEXT NOT NULL,
            password TEXT NOT NULL,
            avatar BLOB,
            birthday DATE NOT NULL,
            gender TEXT NOT NULL,
            goal INTEGER NOT NULL,
            activity_level INTEGER NOT NULL,
            height INTEGER NOT NULL,
            healthActive BOOLEAN NOT NULL
        );
        """

        var createTableStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                // Commit transaction
                sqlite3_exec(db, "COMMIT", nil, nil, nil)
            } else {
                // Rollback transaction
                sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
                print("user table could not be created.")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("CREATE TABLE statement could not be prepared. Error: \(errorMessage)")
            // Rollback transaction
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
        }
        
        sqlite3_finalize(createTableStatement)
    }

    func insert(name: String, username: String, email: String, password: String, avatar: Data?, birthday: Date, gender: String, goal: Int, activityLevel: Int, height: Int, healthActive: Bool) {
        let insertStatementString = "INSERT INTO user (name, username, email, password, avatar, birthday, gender, goal, activity_level, height, healthActive) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        
        // Hash the password using SHA-256
        let passwordHash = SHA256.hash(data: Data(password.utf8)).compactMap { String(format: "%02x", $0) }.joined()
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (passwordHash as NSString).utf8String, -1, nil) // Bind hashed password
            if let avatar = avatar {
                sqlite3_bind_blob(insertStatement, 5, (avatar as NSData).bytes, Int32(avatar.count), nil)
            } else {
                sqlite3_bind_blob(insertStatement, 5, nil, -1, nil)
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: birthday)
            sqlite3_bind_text(insertStatement, 6, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, (gender as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 8, Int32(goal))
            sqlite3_bind_int(insertStatement, 9, Int32(activityLevel))
            sqlite3_bind_int(insertStatement, 10, Int32(height))
            sqlite3_bind_int(insertStatement, 11, healthActive ? 1 : 0) // Bind healthActive
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
                // Commit transaction
                sqlite3_exec(db, "COMMIT", nil, nil, nil)
            } else {
                print("Could not insert row.")
                // Rollback transaction
                sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }

    func getUsernameById(id: Int) -> String? {
        let queryStatementString = "SELECT username FROM user WHERE user_id = ?;"
        var queryStatement: OpaquePointer? = nil
        var username: String? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(id))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                if let cString = sqlite3_column_text(queryStatement, 0) {
                    username = String(cString: cString)
                } else {
                    print("Could not retrieve username.")
                }
            } else {
                print("Could not retrieve username.")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        sqlite3_finalize(queryStatement)
        return username
    }

    func getLastInsertedProgressID() -> Int {
        let selectStatementString = "SELECT last_insert_rowid();"
        var selectStatement: OpaquePointer? = nil
        var progressID: Int32 = 0
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, selectStatementString, -1, &selectStatement, nil) == SQLITE_OK {
            if sqlite3_step(selectStatement) == SQLITE_ROW {
                progressID = sqlite3_column_int(selectStatement, 0)
            }
        } else {
            print("SELECT statement could not be prepared for progress table.")
        }
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        sqlite3_finalize(selectStatement)
        return Int(progressID)
    }


    func userExists(username: String) -> Bool {
        var queryStatement: OpaquePointer?
        let queryStatementString = "SELECT * FROM user WHERE username = ?;"
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (username as NSString).utf8String, -1, nil)
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                sqlite3_finalize(queryStatement)
                
                // Commit transaction
                sqlite3_exec(db, "COMMIT", nil, nil, nil)
                
                return true // User exists
            }
        }
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        sqlite3_finalize(queryStatement)
        return false // User does not exist
    }

    func emailExists(email: String) -> Bool {
        var queryStatement: OpaquePointer?
        let queryStatementString = "SELECT * FROM user WHERE email = ?;"
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (email as NSString).utf8String, -1, nil)
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                sqlite3_finalize(queryStatement)
                
                // Commit transaction
                sqlite3_exec(db, "COMMIT", nil, nil, nil)
                
                return true // Email exists
            }
        }
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        sqlite3_finalize(queryStatement)
        return false // Email does not exist
    }
    func checkCredentials(username: String, password: String) -> Bool {
        let query = "SELECT COUNT(*) FROM user WHERE username = ? AND password = ?"
        var statement: OpaquePointer?
        var result = false
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (username as NSString).utf8String, -1, nil)
            
            let passwordHash = SHA256.hash(data: Data(password.utf8)).compactMap { String(format: "%02x", $0) }.joined()
            sqlite3_bind_text(statement, 2, (passwordHash as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let count = sqlite3_column_int(statement, 0)
                result = count > 0
            }
        }
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        sqlite3_finalize(statement)
        return result
    }

    func getUserIdByUsername(username: String) -> Int? {
        let query = "SELECT user_id FROM user WHERE username = ?"
        var statement: OpaquePointer?
        var user_id: Int32 = -1
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (username as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                user_id = sqlite3_column_int(statement, 0)
            }
        }
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        sqlite3_finalize(statement)
        
        if user_id != -1 {
            return Int(user_id)
        } else {
            return nil
        }
    }


    func insertOrUpdateAvatarForUser(id: Int, avatar: UIImage?) {
        let existingAvatar = getAvatarFromDB(withID: id)
        
//        if existingAvatar == nil {
//            insertAvatarForUser(id: id, avatar: avatar)
//        } else {
//            updateAvatarForUser(id: id, avatar: avatar)
//        }
        
        updateAvatarForUser(id: id, avatar: avatar)
    }


    func insertAvatarForUser(id: Int, avatar: UIImage?) {
        let insertStatementString = "INSERT INTO user (user_id, avatar) VALUES (?, ?);"
        var insertStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if let data = avatar?.jpegData(compressionQuality: 1.0) {
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(insertStatement, 1, Int32(id))
                sqlite3_bind_blob(insertStatement, 2, (data as NSData).bytes, Int32(data.count), nil)
                
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Successfully inserted row. -- insert")
                    
                } else {
                    print("Could not insert row. -- insert")
                }
            } else {
                print("INSERT statement could not be prepared.")
            }
            sqlite3_finalize(insertStatement)
        } else {
            print("Avatar could not be converted to Data.")
        }
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }

    func updateAvatarForUser(id: Int, avatar: UIImage?) {
        let updateStatementString = "UPDATE user SET avatar = ? WHERE user_id = ?;"
        var updateStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if let data = avatar?.jpegData(compressionQuality: 1.0) {
            if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
                sqlite3_bind_blob(updateStatement, 1, (data as NSData).bytes, Int32(data.count), nil)
                sqlite3_bind_int(updateStatement, 2, Int32(id))
                
                if sqlite3_step(updateStatement) == SQLITE_DONE {
                    print("Successfully updated row. --update")
                    
                } else {
                    print("Could not update row. -- update")
                }
            } else {
                print("UPDATE statement could not be prepared.")
            }
            sqlite3_finalize(updateStatement)
        } else {
            print("Avatar could not be converted to Data.")
        }
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }
    
    func getAvatarFromDB(withID id: Int) -> UIImage? {
        var avatarImage: UIImage?
        let queryStatementString = "SELECT avatar FROM user WHERE user_id = ?;"
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(id))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                if let avatar = sqlite3_column_blob(queryStatement, 0) {
                    let bytes = sqlite3_column_bytes(queryStatement, 0)
                    let data = Data(bytes: avatar, count: Int(bytes))
                    avatarImage = UIImage(data: data)
                }
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
        return avatarImage
    }

    func avatarExists(forID id: Int) -> Bool {
        let queryStatementString = "SELECT avatar FROM user WHERE user_id = ?;"
        var queryStatement: OpaquePointer? = nil
        var exists = false
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(id))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let blob = sqlite3_column_blob(queryStatement, 0)
                let bytes = sqlite3_column_bytes(queryStatement, 0)
                
                if bytes > 0 && blob != nil {
                    exists = true
                }
            }
        }
        
        sqlite3_finalize(queryStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        return exists
    }

    func updateBirthday(id: Int, newBirthday: Date) {
        let updateStatementString = "UPDATE user SET birthday = ? WHERE user_id = ?"
        var updateStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let birthdayString = dateFormatter.string(from: newBirthday)
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (birthdayString as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 2, Int32(id))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        
        sqlite3_finalize(updateStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }
    func getUserBirthday(userID: Int) -> Date? {
        var birthday: Date?
        let queryStatementString = "SELECT birthday FROM user WHERE user_id = ?;"
        var queryStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(userID))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let dateString = String(cString: sqlite3_column_text(queryStatement, 0))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                
                if let date = dateFormatter.date(from: dateString) {
                    birthday = date
                }
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        return birthday
    }

    func getUserHeight(userID: Int) -> Int? {
        var height: Int?
        let queryStatementString = "SELECT height FROM user WHERE user_id = ?;"
        var queryStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(userID))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                height = Int(sqlite3_column_int(queryStatement, 0))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        return height
    }
    func getUserActivityLevel(userID: Int) -> Int? {
        var activityLevel: Int?
        let queryStatementString = "SELECT activity_level FROM user WHERE user_id = ?;"
        var queryStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(userID))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                activityLevel = Int(sqlite3_column_int(queryStatement, 0))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        return activityLevel
    }

    
    func updateUserActivityLevel(userID: Int, newActivityLevel: Int) {
        let updateStatementString = "UPDATE user SET activity_level = ? WHERE user_id = ?;"
        var updateStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(updateStatement, 1, Int32(newActivityLevel))
            sqlite3_bind_int(updateStatement, 2, Int32(userID))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated activity level for user with ID \(userID).")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Could not update activity level for user with ID \(userID). Error: \(errorMessage)")

            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        sqlite3_finalize(updateStatement)
    }

    func getUserGender(userID: Int) -> String? {
        var gender: String?
        let queryStatementString = "SELECT gender FROM user WHERE user_id = ?;"
        var queryStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(userID))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                if let genderCString = sqlite3_column_text(queryStatement, 0) {
                    gender = String(cString: genderCString)
                }
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        return gender
    }

    func getUserGoal(userID: Int) -> Int? {
        var goal: Int?
        let queryStatementString = "SELECT goal FROM user WHERE user_id = ?;"
        var queryStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(userID))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                goal = Int(sqlite3_column_int(queryStatement, 0))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        return goal
    }

    
    func updateUserGoal(userID: Int, newGoal: Int) {
        let updateStatementString = "UPDATE user SET goal = ? WHERE user_id = ?;"
        var updateStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(updateStatement, 1, Int32(newGoal))
            sqlite3_bind_int(updateStatement, 2, Int32(userID))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated user goal.")
            } else {
                print("Could not update user goal.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        sqlite3_finalize(updateStatement)
    }
    func updateName(id: Int, newName: String) {
        let updateStatementString = "UPDATE user SET name = ? WHERE user_id = ?"
        var updateStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (newName as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 2, Int32(id))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        
        sqlite3_finalize(updateStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }
    
    func updateHealthActive(id: Int, isActive: Bool) {
        let updateStatementString = "UPDATE user SET healthActive = ? WHERE user_id = ?;"
        var updateStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(updateStatement, 1, isActive ? 1 : 0)
            sqlite3_bind_int(updateStatement, 2, Int32(id))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated healthActive for user with ID \(id).")
            } else {
                print("Could not update healthActive for user with ID \(id).")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        
        sqlite3_finalize(updateStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }

    
    func getHealthActive(id: Int) -> Bool? {
        let queryStatementString = "SELECT healthActive FROM user WHERE user_id = ?"
        var queryStatement: OpaquePointer? = nil
        var healthActive: Bool? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(id))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let healthActiveValue = sqlite3_column_int(queryStatement, 0)
                healthActive = healthActiveValue != 0
            } else {
                print("Could not retrieve healthActive for ID: \(id)")
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        
        sqlite3_finalize(queryStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        return healthActive
    }

    func getName(id: Int) -> String? {
        let queryStatementString = "SELECT name FROM user WHERE user_id = ?"
        var queryStatement: OpaquePointer? = nil
        var username: String? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(id))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                username = String(cString: queryResultCol1!)
            } else {
                print("Could not retrieve name for ID: \(id)")
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        
        sqlite3_finalize(queryStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        return username
    }
    func updateEmail(id: Int, newEmail: String) {
        let updateStatementString = "UPDATE user SET email = ? WHERE user_id = ?"
        var updateStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (newEmail as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 2, Int32(id))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        
        sqlite3_finalize(updateStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }

    func getEmail(id: Int) -> String? {
        let queryStatementString = "SELECT email FROM user WHERE user_id = ?"
        var queryStatement: OpaquePointer? = nil
        var email: String? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(id))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                email = String(cString: queryResultCol1!)
            } else {
                print("Could not retrieve email for ID: \(id)")
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        
        sqlite3_finalize(queryStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        return email
    }


    func updateUsername(id: Int, newUsername: String) {
        let updateStatementString = "UPDATE user SET username = ? WHERE user_id = ?"
        var updateStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (newUsername as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 2, Int32(id))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }

    func updateHeight(id: Int, newHeight: Int) {
        let updateStatementString = "UPDATE user SET height = ? WHERE user_id = ?"
        var updateStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(updateStatement, 1, Int32(newHeight))
            sqlite3_bind_int(updateStatement, 2, Int32(id))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }
    func updateGender(id: Int, newGender: String) {
        let updateStatementString = "UPDATE user SET gender = ? WHERE user_id = ?"
        var updateStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (newGender as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 2, Int32(id))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }

    func getUsername(id: Int) -> String? {
        let queryStatementString = "SELECT username FROM user WHERE user_id = ?"
        var queryStatement: OpaquePointer? = nil
        var username: String? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(id))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                username = String(cString: queryResultCol1!)
            } else {
                print("Could not retrieve username for ID: \(id)")
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        sqlite3_finalize(queryStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        return username
    }
    func updatePassword(id: Int, newPassword: String) {
        let updateStatementString = "UPDATE user SET password = ? WHERE user_id = ?"
        var updateStatement: OpaquePointer? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        // Hash the new password using SHA-256
        let passwordHash = SHA256.hash(data: Data(newPassword.utf8)).compactMap { String(format: "%02x", $0) }.joined()
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (passwordHash as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 2, Int32(id))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }

    func getPasswordForUser(withId id: Int) -> String? {
        let selectStatementString = "SELECT password FROM user WHERE user_id = ?"
        var selectStatement: OpaquePointer? = nil
        var password: String? = nil
        
        // Begin transaction
        sqlite3_exec(db, "BEGIN", nil, nil, nil)
        
        if sqlite3_prepare_v2(db, selectStatementString, -1, &selectStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(selectStatement, 1, Int32(id))
            
            if sqlite3_step(selectStatement) == SQLITE_ROW {
                let passwordCString = sqlite3_column_text(selectStatement, 0)
                password = String(cString: passwordCString!)
            } else {
                print("Password not found for user with id \(id).")
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        sqlite3_finalize(selectStatement)
        
        // Commit transaction
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        return password
    }

}
