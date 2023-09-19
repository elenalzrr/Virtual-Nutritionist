import UIKit
import SwiftyPickerPopover
import HealthKit

class PlannerVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var userId: Int = 0
    var meals: [String] = []
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    let mealDb = DBManagerMeal()

    @IBOutlet var changeDate: UIButton!
    static var plannerDate = Date()

    @IBOutlet var remainingLabel: UILabel!
    @IBOutlet var exerciseLabel: UILabel!
    @IBOutlet var foodLabel: UILabel!
    @IBOutlet var goalLabel: UILabel!
    var dbPortion = DBManagerFoodPortion()
    var dbGoal = DBManagerGoal()
    var dbFood = DBManagerFood()
    
    @IBOutlet var topView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView = topView
        
        userId = SingletonUser.shared.userId
        meals = mealDb.getNamesForUser(user_id: userId)
        
        foodLabel.text = String(format: "%.0f",dbPortion.getTotalCaloriesForUser(fromDate: PlannerVC.plannerDate, user_id: userId))
        
        getTotalBurnedCalories(forDate: PlannerVC.plannerDate) { totalBurnedCalories in
            DispatchQueue.main.async {
                self.exerciseLabel.text = String(format: "%.0f", totalBurnedCalories)
                self.remainingLabel.text = String(format: "%.0f", (self.dbGoal.getCalories(forUserId: self.userId, date: PlannerVC.plannerDate)! - self.dbPortion.getTotalCaloriesForUser(fromDate: PlannerVC.plannerDate, user_id: self.userId) + totalBurnedCalories))
            }
            

            
        }

        goalLabel.text = String(format: "%.0f",  dbGoal.getCalories(forUserId: userId, date: PlannerVC.plannerDate)!)
        

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM yyyy"

        let calendar = Calendar.current
        let currentDate = Date()

        let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: currentDate)
        let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: currentDate)

        if calendar.isDate(PlannerVC.plannerDate, inSameDayAs: currentDate) {
            self.dateLabel.text = "Today"
        } else if calendar.isDate(PlannerVC.plannerDate, inSameDayAs: tomorrowDate!) {
            self.dateLabel.text = "Tomorrow"
        } else if calendar.isDate(PlannerVC.plannerDate, inSameDayAs: yesterdayDate!) {
            self.dateLabel.text = "Yesterday"
        } else {
            let formattedDate = dateFormatter.string(from: PlannerVC.plannerDate)
            self.dateLabel.text = formattedDate
        }
        
       
        
        self.view.backgroundColor = UIColor(hexString: "#CAF0F8")

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.reloadData()
    }


    func getTotalBurnedCalories(forDate date: Date, completion: @escaping (Double) -> Void) {
        // Verificați dacă funcționalitatea HealthKit este disponibilă pe dispozitiv
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(0)
            return
        }

        let healthStore = HKHealthStore()

        // Verificați dacă aveți permisiunile necesare pentru a accesa datele dorite
        guard let caloriesBurnedType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0)
            return
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: caloriesBurnedType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }

            let totalBurnedCalories = sum.doubleValue(for: HKUnit.kilocalorie())
            completion(totalBurnedCalories)
        }

        healthStore.execute(query)
    }

    @IBAction func changeDateAction(_ sender: Any) {

        guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
            fatalError("Couldn't load LobsterTwo-Bold font")
        }
        
        DatePickerPopover(title: "Change Date")
                    .setDateMode(.date)
                    .setSelectedDate(Date())
                    .setValueChange(action: { _, selectedDate in

                    })
                    .setDoneButton(title:"Save", font:lobsterTwoFont, color:UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),action: { popover, selectedDate in
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "EEEE, d MMMM yyyy"

                        let calendar = Calendar.current
                        let currentDate = Date()

                        let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: currentDate)
                        let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: currentDate)

                        if calendar.isDate(selectedDate, inSameDayAs: currentDate) {
                            self.dateLabel.text = "Today"
                        } else if calendar.isDate(selectedDate, inSameDayAs: tomorrowDate!) {
                            self.dateLabel.text = "Tomorrow"
                        } else if calendar.isDate(selectedDate, inSameDayAs: yesterdayDate!) {
                            self.dateLabel.text = "Yesterday"
                        } else {
                            let formattedDate = dateFormatter.string(from: selectedDate)
                            self.dateLabel.text = formattedDate
                        }
                        
                        PlannerVC.plannerDate = selectedDate
                        SingletonUser.shared.plannerDate = selectedDate
                        self.foodLabel.text = String(format: "%.0f",self.dbPortion.getTotalCaloriesForUser(fromDate: PlannerVC.plannerDate, user_id: self.userId))
                        self.getTotalBurnedCalories(forDate: PlannerVC.plannerDate) { totalBurnedCalories in
                            DispatchQueue.main.async {
                                self.exerciseLabel.text = String(format: "%.0f", totalBurnedCalories)
                                self.remainingLabel.text = String(format: "%.0f", (self.dbGoal.getCalories(forUserId: self.userId, date: PlannerVC.plannerDate)! - self.dbPortion.getTotalCaloriesForUser(fromDate: PlannerVC.plannerDate, user_id: self.userId) + totalBurnedCalories))
                            }
                        }
                        self.goalLabel.text = String(format: "%.0f",  self.dbGoal.getCalories(forUserId: self.userId, date: PlannerVC.plannerDate)!)
                        self.tableView.reloadData()

                        
                    }
                    )
                    .setCancelButton(title:"Cancel", font:lobsterTwoFont, color:UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),action: { _, _ in print("cancel")}
                    )
                    .appear(originView: sender as! UIView, baseViewController: self)
    }
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return meals.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var foodPortions: [(name: String, brand: String, calories: Double, serving_size: Double, fats: Double, protein: Double, carbs: Double)] = []
        foodPortions = dbPortion.getFoodPortions(user_id: userId, meal_name: meals[section], date: PlannerVC.plannerDate)
        
        if foodPortions.isEmpty {
            return 1 // Returnează 1 dacă array-ul foodPortions este gol
        } else {
            return foodPortions.count
        }
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Returnează înălțimea dorită pentru celula de la indexPath specificat
        return 70 // Înălțimea dorită a celulei (în puncte)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plannerCell", for: indexPath)
        
        if let foodCell = cell as? PlannerCell {
            var foodPortions: [(name: String, brand: String, calories: Double, serving_size: Double, fats: Double, protein: Double, carbs: Double)] = []
            foodPortions = dbPortion.getFoodPortions(user_id: userId, meal_name: meals[indexPath.section], date: PlannerVC.plannerDate)

            if indexPath.row < foodPortions.count {
                foodCell.infoLabel.isHidden = false
                let foodPortion = foodPortions[indexPath.row]
                
                if foodPortion.brand != " - " {
                    foodCell.nameLabel.text = foodPortion.name + " - " + foodPortion.brand
                } else {
                    foodCell.nameLabel.text = foodPortion.name
                }
                let unit = dbFood.getUnitByNameAndBrand(name: foodPortion.name, brand: foodPortion.brand)

                foodCell.infoLabel.text = String(format: "%.0f", foodPortion.serving_size) + " " + unit! + ", " + String(format: "%.0f", foodPortion.calories) + " kcal, F: " + String(format: "%.0f", foodPortion.fats) + " g, P: " + String(format: "%.0f", foodPortion.protein) + " g, C: " + String(format: "%.0f", foodPortion.carbs) + " g"

            } else {
                foodCell.nameLabel.text = "No meals available"
                foodCell.infoLabel.isHidden = true
            }
        }
        
        return cell
    }

    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        let meal = meals[section]
        headerView?.textLabel?.text = meal
        headerView?.textLabel?.font = UIFont(name: "LobsterTwo", size: 22)
        headerView?.textLabel?.textColor = UIColor(hexString: "#023E8A")

        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        footerView.backgroundColor = UIColor.clear
        
        let addButton = UIButton(type: .system)
        addButton.setTitle("Add food", for: .normal)
        addButton.titleLabel?.font = UIFont(name: "LobsterTwo", size: 20)
        addButton.setTitleColor(UIColor(hexString: "#023E8A"), for: .normal)
        addButton.addTarget(self, action: #selector(addMealButtonTapped), for: .touchUpInside)
        addButton.tag = section
        addButton.frame = CGRect(x: 15, y: 7, width: footerView.frame.width - 30, height: 30)
        footerView.addSubview(addButton)
        
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }

    @objc func addMealButtonTapped(_ sender: UIButton) {
        let mealId = sender.tag
        
        // Obțineți numele secțiunii
        let headerView = tableView.headerView(forSection: mealId)
        let mealName = headerView?.textLabel?.text ?? ""
        
        // Inițializați mealName.text în SearchFoodVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tableViewController = storyboard.instantiateViewController(withIdentifier: "SearchFood") as? SearchFoodVC {
            tableViewController.modalPresentationStyle = .fullScreen
            tableViewController.mealN = mealName
            SingletonUser.shared.mealN = mealName
            tableViewController.dateAdded = PlannerVC.plannerDate
            
            self.present(tableViewController, animated: true, completion: nil)
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let mealName = self.meals[indexPath.section]
        var foodPortions: [(name: String, brand: String, calories: Double, serving_size: Double, fats: Double, protein: Double, carbs: Double)] = []
        foodPortions = dbPortion.getFoodPortions(user_id: userId, meal_name: mealName, date: PlannerVC.plannerDate)
        
        if indexPath.row >= foodPortions.count {
            // Nu permite ștergerea celulei "No meals found"
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let foodPortion = foodPortions[indexPath.row]
            self.dbPortion.deleteFoodPortion(forUserId: self.userId, date: PlannerVC.plannerDate, mealName: mealName, name: foodPortion.name)
            
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            if foodPortions.count == 1 {
                // Adaugă celula "No meals found" dacă nu mai există alte celule în secțiune
              //  self.meals[indexPath.section] = "No meals found"
                self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
            
            self.tableView.endUpdates()
            
            // Actualizează labelurile aici
            self.foodLabel.text = String(format: "%.0f", self.dbPortion.getTotalCaloriesForUser(fromDate: PlannerVC.plannerDate, user_id: self.userId))
            
            self.getTotalBurnedCalories(forDate: PlannerVC.plannerDate) { totalBurnedCalories in
                DispatchQueue.main.async {
                    self.exerciseLabel.text = String(format: "%.0f", totalBurnedCalories)
                    self.remainingLabel.text = String(format: "%.0f", (self.dbGoal.getCalories(forUserId: self.userId, date: PlannerVC.plannerDate)! - self.dbPortion.getTotalCaloriesForUser(fromDate: PlannerVC.plannerDate, user_id: self.userId) + totalBurnedCalories))
                }
            }
            
            self.goalLabel.text = String(format: "%.0f", self.dbGoal.getCalories(forUserId: self.userId, date: PlannerVC.plannerDate)!)
            
            completion(true)
        }
        
        // Setează aspectul acțiunii de ștergere
        deleteAction.backgroundColor = UIColor(red: 0.886, green: 0.639, blue: 0.702, alpha: 1.0)
        deleteAction.image = UIImage(systemName: "trash.fill")
        // Creează configurația acțiunilor și adaugă acțiunea de ștergere
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        // Returnează configurația acțiunilor
        return swipeConfiguration
    }






}


extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
