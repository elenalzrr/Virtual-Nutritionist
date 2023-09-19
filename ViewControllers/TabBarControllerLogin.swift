import Foundation
import UIKit
import HealthKit
class TabBarControllerLogin:UITabBarController, UITabBarControllerDelegate {
    
    var username: String = ""
    var dbUser = DBManagerUser()
    var avatarp: UIImage!
    var userId: Int = 0
    var birthday: Date?
    var height: Int = 0
    var activityLevel: Int = 0
    var goal: Int = 0
    var age: Int = 0
    var gender: String = ""
    var weight: Double = 0
    var progressid: Int = 0
    var bmr:Int = 0
    var tdee:Int = 0
    var dbProgress = DBManagerProgress()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        userId = SingletonUser.shared.userId
        database()
        
    }
    
    func database() {
     
        username = dbUser.getUsernameById(id: userId)!
        birthday = dbUser.getUserBirthday(userID: userId)
        let ageCalc = AgeCalculator(date: birthday!)
        age = ageCalc.calculateAge(date: birthday!)
        height = dbUser.getUserHeight(userID: userId)!
        gender = dbUser.getUserGender(userID: userId)!
        activityLevel = dbUser.getUserActivityLevel(userID: userId)!
        goal = dbUser.getUserGoal(userID: userId)!
        
        weight = dbProgress.getWeightsForUser(user_id: userId).map({ $0.0 }).reversed().first!
        
        let calCalc = GoalCalculator(weight: weight, height: Double(height), age: age, gender: gender, activity: activityLevel, goal: goal)
        
        bmr = Int(calCalc.calculateBMR(gender: gender, age: age, weight: weight, height: Double(height)))
        
        tdee = Int(calCalc.calculateTDEE(bmr: Double(bmr), activity: activityLevel))
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        database()
        switch tabBarController.selectedIndex {
           
            case 0:
                // Cod specific pentru primul tab
                print("home")
            case 1:
                // Cod specific pentru al doilea tab
                print("planner")
            case 2:
                // Cod specific pentru al treilea tab
                print("profile")
                if let profile = viewController as? ProfileVC {
                    profile.tdeeLabel.text! = String(tdee) + " kcal"
                    profile.bmrLabel.text! = String(bmr) + " kcal"
                    if(dbUser.avatarExists(forID: userId) == true) {
                        profile.avatar.image = dbUser.getAvatarFromDB(withID: userId)
                    }
                    if(profile.appleHealthSwitch.isOn) {
                        print("Este activat")
                       

                    }
                    
                }
            
            default:
                break
            }
    }
}
