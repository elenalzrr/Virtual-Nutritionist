import Foundation
class SingletonUser {
    static let shared = SingletonUser()
    
    var userId: Int = 0
    var mealN: String = ""
    var plannerDate = Date()
    var username: String = ""
    var isLoggedIn: Bool = false
    private init() {}
}
