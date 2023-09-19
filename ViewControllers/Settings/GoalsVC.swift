import UIKit
import Toast

import SwiftyPickerPopover
import SwiftMessages
class GoalsVC: UITableViewController {

    
    @IBOutlet var goalLabel: UILabel!
    
    @IBOutlet var goalButton: UIButton!
    
    @IBOutlet var activityLabel: UILabel!
    
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var activityButton: UIButton!
    var userId: Int = 0
    var dbUser = DBManagerUser()
    var dbGoal = DBManagerGoal()
    var dbProgress = DBManagerProgress()
    private var selectedRowGoal: Int = 0
    private var selectedRowActivity: Int = 0
    private var selectedRowFats: Int = 20
    private var selectedRowCarbs: Int = 50
    private var selectedRowProts: Int = 30
    @IBOutlet var caloriesLabel: UILabel!
    @IBOutlet var fatsLabel: UILabel!
    @IBOutlet var proteinLabel: UILabel!
    @IBOutlet var macrosButton2: UIButton!
    @IBOutlet var macrosButton: UIButton!
    @IBOutlet var macrosButton3: UIButton!
    @IBOutlet var carbsLabel: UILabel!
    var protein: Double = 0
    var carbs: Double = 0
    var calories: Double = 0
    var fats: Double = 0
    var weight: Double = 0
    var age:Int = 0
    var realweight:Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        print("intra aici")
        userId = SingletonUser.shared.userId
        let ageCalc = AgeCalculator(date: self.dbUser.getUserBirthday(userID: self.userId)!)
        age = ageCalc.calculateAge(date: self.dbUser.getUserBirthday(userID: self.userId)!)
        realweight = dbProgress.getWeightsForUser(user_id: userId).map({ $0.0 }).reversed().first!
        
        if(dbUser.getUserGoal(userID: userId) == 0) {
            goalLabel.text = "maintain my weight"
        } else if(dbUser.getUserGoal(userID: userId) == 1) {
            goalLabel.text = "lose weight"
        } else if(dbUser.getUserGoal(userID: userId) == 2) {
            goalLabel.text = "gain weight"
        }
        
        if(dbUser.getUserActivityLevel(userID: userId) == 0) {
            activityLabel.text = "little/no exercise"
        } else if(dbUser.getUserActivityLevel(userID: userId) == 1) {
            activityLabel.text = "light exercise"
        } else if(dbUser.getUserActivityLevel(userID: userId) == 2) {
            activityLabel.text = "moderate exercise"
        } else if(dbUser.getUserActivityLevel(userID: userId) == 3) {
            activityLabel.text = "very active"
        } else if(dbUser.getUserActivityLevel(userID: userId) == 4) {
            activityLabel.text = "extra active"
        }
        
        weight = dbGoal.getLatestWeightForUser(userID: userId)!
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.decimalSeparator = "."
        let weightString = numberFormatter.string(from: NSNumber(value: weight))! + " kg"
        weightLabel.text = weightString

        
        calories = self.dbGoal.getLatestCaloriesForUser(userID: userId)!
        let numberFormatter2 = NumberFormatter()
        numberFormatter2.numberStyle = .none
        let caloriesString = numberFormatter2.string(from: NSNumber(value: calories))! + " kcal"
        caloriesLabel.text = caloriesString
        
        fatsLabel.text = numberFormatter2.string(from: NSNumber(value: dbGoal.getLatestFatsForUser(userID: userId)!))! + " g"
        carbsLabel.text = numberFormatter2.string(from: NSNumber(value: dbGoal.getLatestCarbsForUser(userID: userId)!))! + " g"
        proteinLabel.text = numberFormatter2.string(from: NSNumber(value: dbGoal.getLatestProteinForUser(userID: userId)!))! + " g"
        

        
        
    }
    
    @IBAction func goalAction(_ sender: Any) {
        selectedRowGoal = dbUser.getUserGoal(userID: userId)!

        guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
            fatalError("Couldn't load LobsterTwo-Bold font")
        }
        
                let displayStringFor:((String?)->String?)? = { string in
                    if let s = string {
                        switch(s){
                        case "value 1":
                            return "maintain my weight"
                        case "value 2":
                            return "lose weight"
                        case "value 3":
                            return "gain weight"
                        default:
                            return s
                        }
                    }
                    return nil
                }
                
                let p = StringPickerPopover(title: "I want to...", choices: ["value 1","value 2","value 3"])
                    .setDisplayStringFor(displayStringFor)
                    .setValueChange(action: { _, _, selectedString in
                        
                    })
                    .setDoneButton(
                        font: lobsterTwoFont,
                        action: { popover, selectedRow, selectedString in
                            self.selectedRowGoal = selectedRow
                            if(selectedRow == 0) {
                                self.goalLabel.text = "maintain my weight"
                            }
                            if(selectedRow == 1) {
                                self.goalLabel.text = "lose weight"
                            }
                            
                            if(selectedRow == 2) {
                                self.goalLabel.text = "gain weight"
                            }

                            self.dbUser.updateUserGoal(userID: self.userId, newGoal: self.selectedRowGoal)
                            let gcal = GoalCalculator(weight: self.realweight,
                                                      height: Double(self.dbUser.getUserHeight(userID: self.userId)!),
                                                      age: self.age,
                                                      gender: self.dbUser.getUserGender(userID: self.userId)!,
                                                      activity: self.dbUser.getUserActivityLevel(userID: self.userId)!,
                                                      goal: self.dbUser.getUserGoal(userID: self.userId)!)
                            let bmr = gcal.calculateBMR(gender: self.dbUser.getUserGender(userID: self.userId)!,
                                                         age: self.age,
                                                         weight: self.realweight,
                                                         height: Double(self.dbUser.getUserHeight(userID: self.userId)!))
                            let tdee = gcal.calculateTDEE(bmr: bmr, activity: self.selectedRowActivity)
                            self.calories = gcal.calculateCaloriesNeeded(tdee: tdee, goal: self.selectedRowGoal)
                            self.protein = gcal.calculateProtein(calories: self.calories)
                            self.carbs = gcal.calculateCarbs(calories: self.calories)
                            self.fats = gcal.calculateFat(totalCalories: self.calories)
                            self.dbGoal.insert(user_id: self.userId, calories: self.calories, protein: self.protein, fats: self.fats, carbs: self.carbs, weight: self.weight, date: Date())
                            
                            let numberFormatter2 = NumberFormatter()
                            numberFormatter2.numberStyle = .none
                            let caloriesString = numberFormatter2.string(from: NSNumber(value: self.calories))! + " kcal"
                            self.caloriesLabel.text = caloriesString
                            
                            self.fatsLabel.text = numberFormatter2.string(from: NSNumber(value: self.fats))! + " g"
                            self.carbsLabel.text = numberFormatter2.string(from: NSNumber(value: self.carbs))! + " g"
                            self.proteinLabel.text = numberFormatter2.string(from: NSNumber(value: self.protein))! + " g"
                            
                            
                    })
                    .setCancelButton(font:lobsterTwoFont,
                                     action: {_, _, _ in
                         })
                .setSelectedRow(selectedRowGoal)
        p.appear(originView: sender as! UIView, baseViewController: self)
    }
    
    
    
    @IBAction func activityAction(_ sender: Any) {
        selectedRowActivity = dbUser.getUserActivityLevel(userID: userId)!
        guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
            fatalError("Couldn't load LobsterTwo-Bold font")
        }
        
                let displayStringFor:((String?)->String?)? = { string in
                    if let s = string {
                        switch(s){
                        case "value 1":
                            return "little/no exercise"
                        case "value 2":
                            return "light exercise"
                        case "value 3":
                            return "moderate exercise(3-5 days/wk)"
                        case "value 4":
                            return "very active(6-7 days/wk)"
                        case "value 5":
                            return "extra active(very active & physical job)"
                        default:
                            return s
                        }
                    }
                    return nil
                }
                
                let p = StringPickerPopover(title: "Activity", choices: ["value 1","value 2","value 3","value 4","value 5"])
                    .setDisplayStringFor(displayStringFor)
                    .setValueChange(action: { _, _, selectedString in
                        
                    })
                    .setDoneButton(
                        font: lobsterTwoFont,
                        action: { popover, selectedRow, selectedString in
                            self.selectedRowActivity = selectedRow
                            if(selectedRow == 0) {
                                self.activityLabel.text = "little/no exercise"
                            }
                            if(selectedRow == 1) {
                                self.activityLabel.text = "light exercise"
                            }
                            
                            if(selectedRow == 2) {
                                self.activityLabel.text = "moderate exercise"
                            }
                            if(selectedRow == 3) {
                                self.activityLabel.text = "very active"
                            }
                            if(selectedRow == 4) {
                                self.activityLabel.text = "extra active"
                            }
                            
                            self.dbUser.updateUserActivityLevel(userID: self.userId, newActivityLevel: self.selectedRowActivity)
                            
                            let gcal = GoalCalculator(weight: self.realweight,
                                                      height: Double(self.dbUser.getUserHeight(userID: self.userId)!),
                                                      age: self.age,
                                                      gender: self.dbUser.getUserGender(userID: self.userId)!,
                                                      activity: self.dbUser.getUserActivityLevel(userID: self.userId)!,
                                                      goal: self.dbUser.getUserGoal(userID: self.userId)!)
                            let bmr = gcal.calculateBMR(gender: self.dbUser.getUserGender(userID: self.userId)!,
                                                         age: self.age,
                                                         weight: self.realweight,
                                                         height: Double(self.dbUser.getUserHeight(userID: self.userId)!))
                            let tdee = gcal.calculateTDEE(bmr: bmr, activity: self.selectedRowActivity)
                            self.calories = gcal.calculateCaloriesNeeded(tdee: tdee, goal: self.selectedRowGoal)
                            self.protein = gcal.calculateProtein(calories: self.calories)
                            self.carbs = gcal.calculateCarbs(calories: self.calories)
                            self.fats = gcal.calculateFat(totalCalories: self.calories)
                            self.dbGoal.insert(user_id: self.userId, calories: self.calories, protein: self.protein, fats: self.fats, carbs: self.carbs, weight: self.weight, date: Date())
                            
                            let numberFormatter2 = NumberFormatter()
                            numberFormatter2.numberStyle = .none
                            let caloriesString = numberFormatter2.string(from: NSNumber(value: self.calories))! + " kcal"
                            self.caloriesLabel.text = caloriesString
                            
                            self.fatsLabel.text = numberFormatter2.string(from: NSNumber(value: self.fats))! + " g"
                            self.carbsLabel.text = numberFormatter2.string(from: NSNumber(value: self.carbs))! + " g"
                            self.proteinLabel.text = numberFormatter2.string(from: NSNumber(value: self.protein))! + " g"
                            
                            
                            
                    })
                    .setCancelButton(font:lobsterTwoFont,
                                     action: {_, _, _ in
                         })
                .setSelectedRow(selectedRowActivity)
        p.appear(originView: sender as! UIView, baseViewController: self)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goals" {
            if let tabBarController = segue.destination as? UITabBarController {
                tabBarController.selectedIndex = 2
                tabBarController.modalPresentationStyle = .fullScreen
            }
        }
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 2 {
            guard let lobsterTwoFontBold = UIFont(name: "LobsterTwo-Bold", size: 24) else {
                fatalError("Couldn't load LobsterTwo-Bold font")
            }
            guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 18) else {
                fatalError("Couldn't load LobsterTwo-Bold font")
            }
            let alertController = UIAlertController(title: "Please enter the new goal weight", message: nil, preferredStyle: .alert)
            
            let titleString = NSAttributedString(string: "Please enter the new goal weight", attributes: [
                .foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                .font: lobsterTwoFontBold
            ])
            alertController.setValue(titleString, forKey: "attributedTitle")
            
            alertController.addTextField(configurationHandler: { textField in
                self.weight = self.dbGoal.getLatestWeightForUser(userID: self.userId)!
                let numberFormatter = NumberFormatter()
                numberFormatter.minimumFractionDigits = 2
                numberFormatter.maximumFractionDigits = 2
                numberFormatter.decimalSeparator = "."
                let weightString = numberFormatter.string(from: NSNumber(value: self.weight))!
                textField.placeholder = weightString
                textField.textColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                textField.font = lobsterTwoFont
                textField.keyboardType = .decimalPad
            })
            
            alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak alertController] _ in
                guard let alertController = alertController, let textField = alertController.textFields?.first else {
                    return
                }
                
                let trimmedText = textField.text?.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
                guard let weight = trimmedText, !weight.replacingOccurrences(of: ",", with: ".").isEmpty, self.isNumeric(weight.replacingOccurrences(of: ",", with: ".")) == true else {
                    let errorAlert = UIAlertController(title: "Error", message: "Please enter a valid weight.", preferredStyle: .alert)
                    errorAlert.view.tintColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                    let attributes = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 24)!
                    ]
                    let attributesMessage = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 18)!
                    ]
                    let attributedTitle = NSAttributedString(string: "Error", attributes: attributes)
                    errorAlert.setValue(attributedTitle, forKey: "attributedTitle")
                    let attributedMessage = NSAttributedString(string: "Please enter a valid weight.", attributes: attributesMessage)
                    errorAlert.setValue(attributedMessage, forKey: "attributedMessage")
                    errorAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }
                if let weightD = Double(weight.replacingOccurrences(of: ",", with: ".")) {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.maximumFractionDigits = 2
                    formatter.minimumFractionDigits = 2
                    formatter.decimalSeparator = "."
                    if let formattedWeight = formatter.string(from: NSNumber(value: weightD)) {
                        self.weightLabel.text = formattedWeight + " kg"
                    }
                    self.dbGoal.updateLastWeightForUser(userID: self.userId, newWeight: weightD)

                }
                
                

        
            })
            
            
            saveAction.setValue(UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0), forKey: "titleTextColor")
            alertController.addAction(saveAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            cancelAction.setValue(UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0), forKey: "titleTextColor")
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            guard let lobsterTwoFontBold = UIFont(name: "LobsterTwo-Bold", size: 24) else {
                fatalError("Couldn't load LobsterTwo-Bold font")
            }
            guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 18) else {
                fatalError("Couldn't load LobsterTwo-Bold font")
            }
            let alertController = UIAlertController(title: "Please enter the new calories number", message: nil, preferredStyle: .alert)
            
            let titleString = NSAttributedString(string: "Please enter the new calories number", attributes: [
                .foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                .font: lobsterTwoFontBold
            ])
            alertController.setValue(titleString, forKey: "attributedTitle")
            
            alertController.addTextField(configurationHandler: { textField in
                self.calories = self.dbGoal.getLatestCaloriesForUser(userID: self.userId)!
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .none
                let caloriesString = numberFormatter.string(from: NSNumber(value: self.calories))!
                textField.placeholder = caloriesString
                textField.textColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                textField.font = lobsterTwoFont
            })
            
            alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak alertController] _ in
                guard let alertController = alertController, let textField = alertController.textFields?.first else {
                    return
                }
                textField.keyboardType = .decimalPad
                let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let calories = trimmedText, !calories.isEmpty, self.isNumericCal(calories) == true else {
                    let errorAlert = UIAlertController(title: "Error", message: "You have entered an incorrect number of calories, please try again.", preferredStyle: .alert)
                    errorAlert.view.tintColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                    let attributes = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 24)!
                    ]
                    let attributesMessage = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 18)!
                    ]
                    let attributedTitle = NSAttributedString(string: "Error", attributes: attributes)
                    errorAlert.setValue(attributedTitle, forKey: "attributedTitle")
                    let attributedMessage = NSAttributedString(string: "You have entered an incorrect number of calories, please try again.", attributes: attributesMessage)
                    errorAlert.setValue(attributedMessage, forKey: "attributedMessage")
                    errorAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }
                
                if let caloriesD = Double(calories) {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .none
                   
                    let gcal = GoalCalculator(weight: self.realweight, height: Double(self.dbUser.getUserHeight(userID: self.userId)!), age: self.age, gender: self.self.dbUser.getUserGender(userID: self.userId)!, activity: self.dbUser.getUserActivityLevel(userID: self.userId)!, goal: self.dbUser.getUserGoal(userID: self.userId)!)
                    self.protein = gcal.calculateProtein(calories: caloriesD)
                    self.fats = gcal.calculateFat(totalCalories: caloriesD)
                    self.carbs = gcal.calculateCarbs(calories: caloriesD)
                    self.weight = self.dbGoal.getLatestWeightForUser(userID: self.userId)!
                    if let formattedCal = formatter.string(from: NSNumber(value: caloriesD)) {
                        self.caloriesLabel.text = formattedCal + " kcal"
                        
                        self.dbGoal.insert(user_id: self.userId, calories: caloriesD, protein: self.protein, fats: self.fats, carbs: self.carbs, weight: self.weight, date: Date())
                    }
                    
                    if let formattedFats = formatter.string(from: NSNumber(value: self.fats)) {
                        self.fatsLabel.text = formattedFats + " g"
                    }
                    
                    if let formattedCarbs = formatter.string(from: NSNumber(value: self.carbs)) {
                        self.carbsLabel.text = formattedCarbs + " g"
                    }
                    
                    if let formattedProt = formatter.string(from: NSNumber(value: self.protein)) {
                        self.proteinLabel.text = formattedProt + " g"
                    }
                }

        
            })
            
            
            
            saveAction.setValue(UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0), forKey: "titleTextColor")
            alertController.addAction(saveAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            cancelAction.setValue(UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0), forKey: "titleTextColor")
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
            
        }

    }

    
    func isNumeric(_ string: String) -> Bool {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.allowsFloats = true
        
        if let number = formatter.number(from: string), number.doubleValue >= 30 && number.doubleValue <= 200 {
            return true
        } else {
            return false
        }
    }
    
    func isNumericCal(_ string: String) -> Bool {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.allowsFloats = true
        
        if let number = formatter.number(from: string), number.doubleValue >= 800 && number.doubleValue <= 7000 {
            return true
        } else {
            return false
        }
    }
    func columnMacros(sender: Any) {
        let gcal = GoalCalculator(weight: realweight,
                                  height: Double(self.dbUser.getUserHeight(userID: self.userId)!),
                                  age: age,
                                  gender: self.dbUser.getUserGender(userID: self.userId)!,
                                  activity: self.dbUser.getUserActivityLevel(userID: self.userId)!,
                                  goal: self.dbUser.getUserGoal(userID: self.userId)!)
        self.weight = self.dbGoal.getLatestWeightForUser(userID: userId)!
        self.calories = self.dbGoal.getLatestCaloriesForUser(userID: userId)!
        let choices: [[String]] = [
            (0...100).map { "\($0)%" },
            (0...100).map { "\($0)%" },
            (0...100).map { "\($0)%" }
        ]
        guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
            fatalError("Couldn't load LobsterTwo-Bold font")
        }
        ColumnStringPickerPopover(title: "Macro picker", choices: choices, selectedRows: [0, 1, 2], columnPercents: [0.25, 0.25, 0.25])
            .setDoneButton(title:"Save",
                           font: UIFont(name: "LobsterTwo", size: 22),
                       action: { popover, selectedRows, selectedStrings in
                            print("selected rows \(selectedRows) strings \(selectedStrings)")
                if(selectedRows[0] + selectedRows[1] + selectedRows[2] == 100){
                    let title =  "The changes have been saved successfully."
                    self.protein = gcal.calculateProtein(calories: self.calories, proteinPercentage: Double(selectedRows[1])/100)
                    self.fats = gcal.calculateFat(totalCalories: self.calories, fatPercentage: Double(selectedRows[0])/100)
                    self.carbs = gcal.calculateCarbs(calories: self.calories, carbPercentage: Double(selectedRows[2])/100)
                    let numberFormatter2 = NumberFormatter()
                    numberFormatter2.numberStyle = .none
                    let proteinString = numberFormatter2.string(from: NSNumber(value: self.protein))! + " g"
                    let fatString = numberFormatter2.string(from: NSNumber(value: self.fats))! + " g"
                    let carbString = numberFormatter2.string(from: NSNumber(value: self.carbs))! + " g"
                    self.proteinLabel.text = proteinString
                    self.fatsLabel.text = fatString
                    self.carbsLabel.text = carbString
                    
                    self.dbGoal.insert(user_id: self.userId, calories: self.calories, protein: self.protein, fats: self.fats, carbs: self.carbs, weight: self.weight, date: Date())

                    // create a new style
                    var style = ToastStyle()

                    // this is just one of many style options
                    style.messageColor = .white
                    style.backgroundColor = UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0)
                    style.titleFont = lobsterTwoFont
                    style.messageFont = lobsterTwoFont
                    // present the toast with the new style
                    self.view.makeToast(title, duration: 2.0, position: .top, style: style)



                    // toggle "tap to dismiss" functionality
                    ToastManager.shared.isTapToDismissEnabled = true

                    // toggle queueing behavior
                    ToastManager.shared.isQueueEnabled = true
                    
                } else {
                    let title = "Incorrect percentage: " + String(selectedRows[0] + selectedRows[1] + selectedRows[2]) + "%"
                    
                    // create a new style
                    var style = ToastStyle()

                    // this is just one of many style options
                    style.messageColor = .white
                    style.backgroundColor = UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0)
                    style.titleFont = lobsterTwoFont
                    style.messageFont = lobsterTwoFont
                    // present the toast with the new style
                    self.view.makeToast(title, duration: 2.0, position: .top, style: style)



                    // toggle "tap to dismiss" functionality
                    ToastManager.shared.isTapToDismissEnabled = true

                    // toggle queueing behavior
                    ToastManager.shared.isQueueEnabled = true
                    
                }
            })
            .setCancelButton(font: lobsterTwoFont,
                         action: { _,_,_ in
                        print("cancel")})
            .setValueChange(action: { [self] _, selectedRows, selectedStrings in
                        print("current strings: \(selectedStrings)")
                if(selectedRows[0] + selectedRows[1] + selectedRows[2] == 100){
                    print("Procent corect")
                    
                    protein = gcal.calculateProtein(calories: calories, proteinPercentage: Double(selectedRows[1])/100)
                    fats = gcal.calculateFat(totalCalories: calories, fatPercentage: Double(selectedRows[0])/100)
                    carbs = gcal.calculateCarbs(calories: calories, carbPercentage: Double(selectedRows[2])/100)
                    
                    let numberFormatter2 = NumberFormatter()
                    numberFormatter2.numberStyle = .none
                    let proteinString = numberFormatter2.string(from: NSNumber(value: protein))! + " g"
                    let fatString = numberFormatter2.string(from: NSNumber(value: fats))! + " g"
                    let carbString = numberFormatter2.string(from: NSNumber(value: carbs))! + " g"
                    let title = "Fats: " + fatString + " Protein: " + proteinString + " Carbs: " + carbString
                    
                    
                    // create a new style
                    var style = ToastStyle()

                    // this is just one of many style options
                    style.messageColor = .white
                    style.backgroundColor = UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0)
                    style.titleFont = lobsterTwoFont
                    style.messageFont = lobsterTwoFont
                    // present the toast with the new style
                    self.view.makeToast(title, duration: 2.0, position: .top, style: style)



                    // toggle "tap to dismiss" functionality
                    ToastManager.shared.isTapToDismissEnabled = true

                    // toggle queueing behavior
                    ToastManager.shared.isQueueEnabled = true
                    
                } else {
                    let title = "Incorrect percentage: " + String(selectedRows[0] + selectedRows[1] + selectedRows[2]) + "%"
                    // create a new style
                    var style = ToastStyle()

                    // this is just one of many style options
                    style.messageColor = .white
                    style.backgroundColor = UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0)
                    style.titleFont = lobsterTwoFont
                    style.messageFont = lobsterTwoFont

                    // present the toast with the new style
                    self.view.makeToast(title, duration: 1.0, position: .top, style: style)



                    // toggle "tap to dismiss" functionality
                    ToastManager.shared.isTapToDismissEnabled = true

                    // toggle queueing behavior
                    ToastManager.shared.isQueueEnabled = true
                    
                }

            })
            .setFonts([UIFont(name: "LobsterTwo", size: 22), UIFont(name: "LobsterTwo", size: 22),UIFont(name: "LobsterTwo", size: 22)])
            .setFontColors([UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0),
                        UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0),
                        UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0)])
            .setSelectedRows([selectedRowFats,selectedRowProts,selectedRowCarbs])
            .appear(originView: sender as! UIView, baseViewController: self)
    }


    
    @IBAction func macrosAction(_ sender: Any) {
        columnMacros(sender: sender)
    }
    
    
    @IBAction func macrosAction2(_ sender: Any) {
        columnMacros(sender: sender)
    }
    
    
    @IBAction func macrosAction3(_ sender: Any) {
        columnMacros(sender: sender)
    }
    
}
