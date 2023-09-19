import UIKit
import PMAlertController
import HealthKit
class ProfileVC: UITableViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet var avatar: UIImageView!
    
    @IBOutlet var changeAvatar: UIButton!
    
    @IBOutlet var bmrLabel: UILabel!
    
    @IBOutlet var appleHealthSwitch: UISwitch!
    @IBOutlet var tdeeLabel: UILabel!
    var dbUser = DBManagerUser()
    var username: String = ""
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
    private let healthStore = HKHealthStore()
    
    private func fetchEnergyBurned(completion: @escaping (Double) -> Void) {
        let energyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let now = Date()
        let startOfDay = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: energyBurned, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch energy burned: \(String(describing: error?.localizedDescription))")
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.kilocalorie()))
        }
        
        healthStore.execute(query)
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("__________________________________________")
        var energyBurnedResult: Double = 0.0

        // Apelați funcția fetchEnergyBurned
        fetchEnergyBurned { energyBurned in
            // Actualizați valoarea variabilei
            energyBurnedResult = energyBurned

            // Printați rezultatul
            print("Energy Burned: \(energyBurnedResult) kcal")
        }

        // Puteți accesa valoarea variabilei în afara blocului
        print("Energy Burned Result: \(energyBurnedResult) kcal")
        print("__________________________________________")

        if let tabBarController = tabBarController as? TabBarControllerLogin {
            username = tabBarController.username
            userId = tabBarController.userId
        }
        if(dbUser.avatarExists(forID: userId)) {
            avatar.image = dbUser.getAvatarFromDB(withID: userId)
        }
        database()
        tdeeLabel.text! = String(tdee) + " kcal"
        bmrLabel.text! = String(bmr) + " kcal"
        

        
        
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
        
        appleHealthSwitch.isOn = dbUser.getHealthActive(id: userId)!
    }
    @IBAction func changeAvatarAction(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            avatar.image = selectedImage
            dbUser.insertOrUpdateAvatarForUser(id: userId, avatar: selectedImage)
            avatar.setNeedsDisplay()
        }
        dismiss(animated: true, completion: nil)
    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "logout" {
            let alertVC = PMAlertController(title: "Logout", description: "Are you sure you want to log out?", image: nil, style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: nil))
            
            alertVC.addAction(PMAlertAction(title: "Logout", style: .default, action: { [weak self] in
                guard let self = self else { return }
                SingletonUser.shared.isLoggedIn = false
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "name")
                defaults.removeObject(forKey: "username")
                defaults.removeObject(forKey: "mail")
                defaults.removeObject(forKey: "weight")
                defaults.removeObject(forKey: "height")
                defaults.removeObject(forKey: "goalweight")
                defaults.removeObject(forKey: "selectedDate")
                defaults.removeObject(forKey: "selectedSegmentIndex")
                defaults.removeObject(forKey: "lifestyle")
                defaults.removeObject(forKey: "goal")
                
                self.performSegue(withIdentifier: identifier, sender: sender)
            }))


            self.present(alertVC, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }

    
    @IBAction func appleHealthAct(_ sender: Any) {
        if (sender as AnyObject).isOn {
            requestHealthKitAuthorization()
            dbUser.updateHealthActive(id: userId, isActive: true)
            appleHealthSwitch.isOn = dbUser.getHealthActive(id: userId)!

            } else {
                print("izz off")
                dbUser.updateHealthActive(id: userId, isActive: false)
                appleHealthSwitch.isOn = dbUser.getHealthActive(id: userId)!
            }
    }
    
    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let stepsCount = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let energyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [stepsCount, energyBurned]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if success {
                print("HealthKit authorization granted")
            } else {
                print("HealthKit authorization failed: \(String(describing: error?.localizedDescription))")
            }
        }
    }

}
