import UIKit

class CreateAccount3VC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var pickerViewButton: UIButton!
    
    
    @IBOutlet var pickerViewLifestyleButton: UIButton!
    
    var pickerViewGoal: UIPickerView!
    var pickerViewLifestyle: UIPickerView!
    
    var mindex: Int = 0
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 2
    var selectedRow = 0
    
    var nameTF: String = ""
    var mailTF: String = ""
    var usernameTF: String = ""
    var passwordTF: String = ""
    var birthday = Date()
    var heightTF: String = ""
    var weightTF: String = ""
    var gender: String = ""
    var goalweightTF: String = ""
    var goalIndex: Int = 0
    var activityIndex: Int = 0
    

    var dbUser = DBManagerUser()
    var dbProgress = DBManagerProgress()
    var dbGoal = DBManagerGoal()
    var dbReminder = DBManagerReminder()
    var dbMeal = DBManagerMeal()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let buttonTitle = UserDefaults.standard.string(forKey: "lifestyle") {
            pickerViewLifestyleButton.setTitle(buttonTitle, for: .normal)
        }
        
        if let buttonTitle2 = UserDefaults.standard.string(forKey: "goal") {
            pickerViewButton.setTitle(buttonTitle2, for: .normal)
        }
    
    }
    
    var goalPicker : [String] =
    [
        "maintain my weight",
        "lose weight",
        "gain weight"
    ]
    
    var lifestylePicker : [String] =
    [
        "little/no exercise",
        "light exercise",
        "moderate exercise (3-5 days/wk)",
        "very active (6-7 days/wk)",
        "extra active (very active & physical job)"
    ]
    @IBAction func popupPickerLifestyle(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height:screenHeight))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "Select your activity level", message: "", preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.sourceView = pickerViewLifestyleButton
        alert.popoverPresentationController?.sourceRect = pickerViewLifestyleButton.bounds
        
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
        }))
        
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { (UIAlertAction) in
            self.selectedRow = pickerView.selectedRow(inComponent: 0)
            let selected = Array(self.lifestylePicker)[self.selectedRow]
            let trimSpot = selected.firstIndex(of: "(") ?? selected.endIndex
            let trimmed = selected[..<trimSpot]
            var name = String(trimmed)
            if(name == "extra active "){
                name = name + "              "
                print(name)
            } else if (name == "very active ") {
                name = name + "              "
            } else if (name == "light exercise") {
                name = name + "                        "
            } else if (name == "little/no exercise") {
                name = name + "     "
            }
            self.pickerViewLifestyleButton.setTitle(name, for: .normal)
            UserDefaults.standard.set(name, forKey: "lifestyle")
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        pickerViewLifestyle = pickerView
    }
    
    @IBAction func popUpPicker(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height:screenHeight))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "Select your goal", message: "", preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.sourceView = pickerViewButton
        alert.popoverPresentationController?.sourceRect = pickerViewButton.bounds
        
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
        }))
        
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { (UIAlertAction) in
            self.selectedRow = pickerView.selectedRow(inComponent: 0)
            let selected = Array(self.goalPicker)[self.selectedRow]
            let name = selected
            self.pickerViewButton.setTitle(name, for: .normal)
            UserDefaults.standard.set(name, forKey: "goal")
        }))
        
        self.present(alert, animated: true, completion: nil)
        pickerViewGoal = pickerView
    }
    
    //Functiile pentru pickerView
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        switch pickerView{
        case pickerViewGoal:
            label.text = Array(goalPicker)[row]
        case pickerViewLifestyle:
            label.text = Array(lifestylePicker)[row]
        default:
            label.text = ""
        }
        label.sizeToFit()
        return label
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView{
        case pickerViewGoal:
            return goalPicker.count
        case pickerViewLifestyle:
            return lifestylePicker.count
        default:
            return 0
        }
        
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let prefix1 = "little/no exercise"
        let prefix2 = "light exercise"
        let prefix3 = "moderate exercise"
        let prefix4 = "very active"
        let prefix5 = "extra active"
        if(pickerViewLifestyleButton.currentTitle!.hasPrefix(prefix1)) {
            activityIndex = 0
        } else if(pickerViewLifestyleButton.currentTitle!.hasPrefix(prefix2)) {
            activityIndex = 1
        } else if(pickerViewLifestyleButton.currentTitle!.hasPrefix(prefix3)) {
            activityIndex = 2
        } else if(pickerViewLifestyleButton.currentTitle!.hasPrefix(prefix4)) {
            activityIndex = 3
        } else if(pickerViewLifestyleButton.currentTitle!.hasPrefix(prefix5)) {
            activityIndex = 4
        }
        
        if(pickerViewButton.currentTitle! == "maintain my weight") {
            goalIndex = 0
        } else if(pickerViewButton.currentTitle! == "lose weight") {
            goalIndex = 1
        } else if(pickerViewButton.currentTitle! == "gain weight") {
            goalIndex = 2
        }
        
        
        if identifier == "register" {
            dbUser.insert(name: nameTF, username: usernameTF.lowercased(), email: mailTF, password: passwordTF, avatar: nil, birthday: birthday, gender: gender, goal: goalIndex, activityLevel: activityIndex, height: Int(heightTF)!,healthActive: false)
            
            dbProgress.insertProgress(user_id: dbUser.getLastInsertedProgressID(), date: Date(), weight: Double(weightTF.replacingOccurrences(of: ",", with: "."))!)
            
            
            let ageCalc = AgeCalculator(date: birthday)
            
            let goal = GoalCalculator(weight: Double(weightTF.replacingOccurrences(of: ",", with: "."))!, height: Double(heightTF.replacingOccurrences(of: ",", with: "."))!, age: ageCalc.calculateAge(date: birthday), gender: gender, activity: activityIndex, goal: goalIndex)
            
            let calories = goal.calculateCaloriesNeeded(tdee: goal.calculateTDEE(bmr: goal.calculateBMR(gender: gender, age: ageCalc.calculateAge(date: birthday), weight: Double(weightTF.replacingOccurrences(of: ",", with: "."))!, height: Double(heightTF.replacingOccurrences(of: ",", with: "."))!), activity: activityIndex), goal: goalIndex)
            

            dbGoal.insert(user_id: dbUser.getLastInsertedProgressID(), calories: calories,
                          protein: goal.calculateProtein(calories: calories),
                          fats: goal.calculateFat(totalCalories: calories),
                          carbs: goal.calculateCarbs(calories: calories),
                          weight: Double(goalweightTF.replacingOccurrences(of: ",", with: "."))!,
                          date: Date())

            
            
            
            let date = Date() // Data actuală
            let calendar = Calendar.current // Calendarul curent
            let hour = 8 // Ora (în format de 24 de ore)
            let minute = 30 // Minutele
            let components = DateComponents(year: calendar.component(.year, from: date), month: calendar.component(.month, from: date), day: calendar.component(.day, from: date), hour: hour, minute: minute)
            let newDate = calendar.date(from: components)! // Noua dată cu ora 15:20

            dbReminder.insertReminder(user_id: dbUser.getLastInsertedProgressID(), name: "Breakfast", date: newDate, isActive: false)
            

            let hour2 = 13 // Ora (în format de 24 de ore)
            let minute2 = 30 // Minutele
            let components2 = DateComponents(year: calendar.component(.year, from: date), month: calendar.component(.month, from: date), day: calendar.component(.day, from: date), hour: hour2, minute: minute2)
            let newDate2 = calendar.date(from: components2)! // Noua dată cu ora 15:20
            
            dbReminder.insertReminder(user_id: dbUser.getLastInsertedProgressID(), name: "Lunch", date: newDate2, isActive: false)
            

            let hour3 = 18 // Ora (în format de 24 de ore)
            let minute3 = 30 // Minutele
            let components3 = DateComponents(year: calendar.component(.year, from: date), month: calendar.component(.month, from: date), day: calendar.component(.day, from: date), hour: hour3, minute: minute3)
            let newDate3 = calendar.date(from: components3)! // Noua dată cu ora 15:20
            
            dbReminder.insertReminder(user_id: dbUser.getLastInsertedProgressID(), name: "Dinner", date: newDate3, isActive: false)
            
            dbMeal.insert(user_id: dbUser.getLastInsertedProgressID(), date: Date(), name: "Breakfast",inUse: true)
           
            
            dbMeal.insert(user_id: dbUser.getLastInsertedProgressID(), date: Date(), name: "Lunch",inUse: true)
           
            
            dbMeal.insert(user_id: dbUser.getLastInsertedProgressID(), date: Date(), name: "Dinner",inUse: true)

            
            
            guard let lobsterTwoFontBold = UIFont(name: "LobsterTwo-Bold", size: 24) else {
                fatalError("Couldn't load LobsterTwo-Bold font")
            }
            
            
            let alertController = UIAlertController(title: "Account created", message: "Welcome!", preferredStyle: .alert)

            let titleAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                NSAttributedString.Key.font: lobsterTwoFontBold
            ]
            let titleString = NSAttributedString(string: "Account created", attributes: titleAttributes)

            alertController.setValue(titleString, forKey: "attributedTitle")

            
            if let font = UIFont(name: "LobsterTwo", size: 18) {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                    .font: font
                ]
                let messageString = NSAttributedString(string: "Welcome!", attributes: attributes)
                alertController.setValue(messageString, forKey: "attributedMessage")
            }

            alertController.setValue(titleString, forKey: "attributedTitle")
            alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)

            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                 self.performSegue(withIdentifier: "register", sender: nil)
            }
            okAction.setValue(UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0), forKey: "titleTextColor")

            alertController.addAction(okAction)

            
            self.present(alertController, animated: true, completion: nil)
        }
        return true
        
    }
    
}
