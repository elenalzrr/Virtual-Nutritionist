import UIKit
import Toast
import SwiftUI
class AddFoodVC: UITableViewController, UITextFieldDelegate {
    
    var foodId: Int = 0
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var brandLabel: UILabel!
    
    @IBOutlet var servingTF: UITextField!
    
    @IBOutlet var fatsLabel: UILabel!
    @IBOutlet var caloriesLabel: UILabel!
    
    @IBOutlet var proteinLabel: UILabel!
    
    @IBOutlet var carbsLabel: UILabel!
    
    @IBOutlet var chartView: UIView!
    var dbFood = DBManagerFood()
    var dbPortion = DBManagerFoodPortion()
    var dateAdded: Date!
    var food: (String, String, Double, Double, Double, Double, Double)? = nil
    var childView = UIHostingController(rootView: CaloriesRatioChart())
    var macrosRatio: [Double] = []
    var mealN: String = ""
    var caloriesD: Double!
    var proteinD: Double!
    var carbsD: Double!
    var fatsD: Double!
    var userId: Int = 0
    var servingD: Double!
    
    @objc func servingEditingChanged() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(delayedUpdate), object: nil)
        perform(#selector(delayedUpdate), with: nil, afterDelay: 1)
    }

    @objc func delayedUpdate() {
        updateNutritionLabels()
    }



    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        userId = SingletonUser.shared.userId
        
        servingTF.addTarget(self, action: #selector(servingEditingChanged), for: .editingChanged)



        food = dbFood.getFoodDataForId(for: foodId)
        servingTF.delegate = self
        servingTF.keyboardType = .decimalPad
        nameLabel.text = food!.0
        brandLabel.text = food!.1
        servingTF.text = String(food!.2)
        caloriesD = food!.3
        proteinD = food!.4
        fatsD = food!.5
        carbsD = food!.6
        servingD = food!.2
        let calories = String(format: "%.2f", food!.3)
        let protein = String(format: "%.2f", food!.4)
        let fats = String(format: "%.2f", food!.5)
        let carbs = String(format: "%.2f", food!.6)
        macrosRatio = [food!.4,food!.5,food!.6]
        caloriesLabel.text = calories + " kcal"
        proteinLabel.text = protein + " g"
        fatsLabel.text = fats + " g"
        carbsLabel.text = carbs + " g"

        let placeholderText = "serving size"
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)]
        servingTF.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = "" // Șterge conținutul text field-ului când este apăsat
        return true // Permite editarea textului în continuare
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        servingD = Double(servingTF.text!)
        updateNutritionLabels()
    }


    func updateNutritionLabels() {

        if !servingTF.text!.isEmpty, let quantity = Double(servingTF.text!.replacingOccurrences(of: ",", with: ".")) {
            let nutritionCalculator = FoodCalculator(caloriesPer100g: food!.3, proteinPer100g: food!.4, fatsPer100g: food!.5, carbsPer100g: food!.6)
            updateLabels(with: nutritionCalculator, quantity: quantity)
        }

    }

    func updateLabels(with nutritionCalculator: FoodCalculator, quantity: Double) {
        let calories = nutritionCalculator.calculateCalories(for: quantity, initialQuantity: 100)
        let protein = nutritionCalculator.calculateProtein(for: quantity, initialQuantity: 100)
        let fats = nutritionCalculator.calculateFats(for: quantity, initialQuantity: 100)
        let carbs = nutritionCalculator.calculateCarbs(for: quantity, initialQuantity: 100)
        caloriesD = calories
        proteinD = protein
        fatsD = fats
        carbsD = carbs
        macrosRatio = [protein,fats,carbs]
        let caloriesText = String(format: "%.2f", calories)
        let proteinText = String(format: "%.2f", protein)
        let fatsText = String(format: "%.2f", fats)
        let carbsText = String(format: "%.2f", carbs)

        caloriesLabel.text = caloriesText + " kcal"
        proteinLabel.text = proteinText + " g"
        fatsLabel.text = fatsText + " g"
        carbsLabel.text = carbsText + " g"

        tableView.reloadData()
    }


    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "saveFood" {
            if(dbPortion.isFoodPortionAlreadyExists(userId: userId, date: SingletonUser.shared.plannerDate, mealName: SingletonUser.shared.mealN, name: nameLabel.text!, brand: brandLabel.text!) == false) {
                dbPortion.insertFoodPortion(foodId: foodId, userId: userId, mealName: SingletonUser.shared.mealN, date: SingletonUser.shared.plannerDate, name: nameLabel.text!, brand: brandLabel.text!, servingSize: servingD, calories: caloriesD, protein: proteinD, fats: fatsD, carbs: carbsD)
            } else {
                guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
                    fatalError("Couldn't load LobsterTwo-Bold font")
                }
                let title = "Food entry already exists for this meal today. Please delete it and add again if you want to change the quantity."
                
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
                return false
            }
            
            
        }
        
        return true
    }

    
    

}
