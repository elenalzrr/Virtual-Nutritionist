import UIKit
import SwiftUI
import HealthKit
import CircularProgressView
import BarChartKit

// https://github.com/bdolewski/CircularProgressView
class HomeVC: UIViewController {

    @IBOutlet var progress: CircularProgressView!
    
    @IBOutlet var calChart: UIView!
    @IBOutlet var caloriesView: UIView!
    
    @IBOutlet var macrosView: UIView!
    var username: String = ""
    var userId: Int = 0
    @IBOutlet var goalLabel: UILabel!
    @IBOutlet var foodLabel: UILabel!
    @IBOutlet var exerciseLabel: UILabel!
    var dbUser = DBManagerUser()
    var dbPortion = DBManagerFoodPortion()
    var dbGoal = DBManagerGoal()
    var goalNr: Double = 0
    var remNr: Double = 0
    
    @IBOutlet var carbsLabel: UILabel!
    @IBOutlet var remainingLabel: UILabel!
    @IBOutlet var carbsRing: CircularProgressView!
    
    @IBOutlet var fatLabel: UILabel!
    @IBOutlet var proteinsLabel: UILabel!
    @IBOutlet var fatsRing: CircularProgressView!
    @IBOutlet var proteinsRing: CircularProgressView!
    
    var totalCarbs: Double = 0
    var eatCarbs: Double = 0
    var totalProteins: Double = 0
    var eatProteins: Double = 0
    var totalFats: Double = 0
    var eatFats: Double = 0
    var weeklyCals: [(String, Double)] = []
    var weeklySteps: [(String, Double)] = []
    
    @IBOutlet var caloriesChart: UIView!
    
    @IBOutlet var stepsChart: UIView!
    
    var childView = UIHostingController(rootView: CaloriesView())
    var childView2 = UIHostingController(rootView: CaloriesView())
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = SingletonUser.shared.userId
        print(SingletonUser.shared.username)
        if let tabBarController = tabBarController as? TabBarControllerLogin {
            tabBarController.delegate = tabBarController
        }
        username = dbUser.getUsernameById(id: userId)!
        foodLabel.text = String(format: "%.0f",dbPortion.getTotalCaloriesForUser(fromDate: Date(), user_id: userId))
        goalLabel.text = String(format: "%.0f",  dbGoal.getCalories(forUserId: userId, date: Date())!)
        goalNr = dbGoal.getCalories(forUserId: userId, date: Date())!
        
        getTotalBurnedCalories(forDate: PlannerVC.plannerDate) { totalBurnedCalories in
            DispatchQueue.main.async {
                self.exerciseLabel.text = String(format: "%.0f", totalBurnedCalories)
                self.remainingLabel.text = String(format: "%.0f", (self.dbGoal.getCalories(forUserId: self.userId, date: Date())! - self.dbPortion.getTotalCaloriesForUser(fromDate: Date(), user_id: self.userId) + totalBurnedCalories))
                self.remNr = (self.dbGoal.getCalories(forUserId: self.userId, date: Date())! - self.dbPortion.getTotalCaloriesForUser(fromDate: Date(), user_id: self.userId) + totalBurnedCalories)
                self.progress.foregroundBarColor = UIColor(red: 0/255.0, green: 119/255.0, blue: 182/255.0, alpha: 1.0)
                self.progress.maximumBarColor = UIColor(red: 3/255.0, green: 4/255.0, blue: 94/255.0, alpha: 1.0)
                self.progress.setProgress(to: self.remNr/self.goalNr, animated: true)
                
            }
        }
        
        totalCarbs = dbGoal.getLatestCarbsForUser(userID: userId)!
        totalFats = dbGoal.getLatestFatsForUser(userID: userId)!
        totalProteins = dbGoal.getLatestProteinForUser(userID: userId)!
        eatCarbs = dbPortion.getTotalCarbsForUser(fromDate: Date(), user_id: userId)
        eatFats = dbPortion.getTotalFatsForUser(fromDate: Date(), user_id: userId)
        eatProteins = dbPortion.getTotalProteinForUser(fromDate: Date(), user_id: userId)
        
        carbsLabel.text = String(format: "%.0f", totalCarbs - eatCarbs) + " g"
        fatLabel.text = String(format: "%.0f", totalFats - eatFats) + " g"
        proteinsLabel.text = String(format: "%.0f", totalProteins - eatProteins) + " g"
        
        fatsRing.foregroundBarColor = UIColor(red: 0/255.0, green: 119/255.0, blue: 182/255.0, alpha: 1.0)
        fatsRing.maximumBarColor = UIColor(red: 3/255.0, green: 4/255.0, blue: 94/255.0, alpha: 1.0)
        fatsRing.setProgress(to: eatFats/totalFats, animated: true)
        
        proteinsRing.foregroundBarColor = UIColor(red: 0/255.0, green: 119/255.0, blue: 182/255.0, alpha: 1.0)
        proteinsRing.maximumBarColor = UIColor(red: 3/255.0, green: 4/255.0, blue: 94/255.0, alpha: 1.0)
        proteinsRing.setProgress(to: eatProteins/totalProteins, animated: true)
        
        carbsRing.foregroundBarColor = UIColor(red: 0/255.0, green: 119/255.0, blue: 182/255.0, alpha: 1.0)
        carbsRing.maximumBarColor = UIColor(red: 3/255.0, green: 4/255.0, blue: 94/255.0, alpha: 1.0)
        carbsRing.setProgress(to: eatCarbs/totalCarbs, animated: true)
        
        
        
        
        caloriesView.layer.borderWidth = 2.5
        caloriesView.layer.borderColor = UIColor(red: 0.95, green: 0.85, blue: 0.88, alpha: 1.0).cgColor
        
        macrosView.layer.borderWidth = 2.5
        macrosView.layer.borderColor = UIColor(red: 0.95, green: 0.85, blue: 0.88, alpha: 1.0).cgColor
        
        weeklyCals = dbPortion.getTotalCaloriesForLast7Days(user_id: userId)
        
        childView = UIHostingController(rootView: CaloriesView(dataDemo: weeklyCals))
        addChild(childView)
        childView.view.frame = caloriesChart.bounds
        childView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childView.view.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
        caloriesChart.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
        caloriesChart.addSubview(childView.view)
        childView.didMove(toParent: self)
        
        
        getTotalStepsForLast7Days { stepsArray in
            DispatchQueue.main.async {
                print("Numărul total de pași în ultimele 7 zile:")
                self.weeklySteps = stepsArray
                self.childView2 = UIHostingController(rootView: CaloriesView(dataDemo: self.weeklySteps))
                self.addChild(self.childView2)
                self.childView2.view.frame = self.stepsChart.bounds
                self.childView2.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.childView2.view.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                self.stepsChart.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                self.stepsChart.addSubview(self.childView2.view)
                self.childView2.didMove(toParent: self)
            }
        }



        
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

    func getTotalStepsForLast7Days(completion: @escaping ([(String, Double)]) -> Void) {
        let healthStore = HKHealthStore()

        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("Step count type not available.")
        }

        let calendar = Calendar.current
        let today = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en_US")

        var totalStepsArray: [(String, Double)] = []

        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)

                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

                let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
                    if let result = result, let sum = result.sumQuantity() {
                        let totalSteps = sum.doubleValue(for: HKUnit.count())

                        let dayOfWeek = dateFormatter.string(from: date)

                        totalStepsArray.append((dayOfWeek, totalSteps))
                    }

                    if i == 6 {
                        completion(totalStepsArray)
                    }
                }

                healthStore.execute(query)
            }
        }
    }


    
}

