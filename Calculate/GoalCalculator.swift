import Foundation

class GoalCalculator {
    
    var weight: Double
    var height: Double
    var age: Int
    var gender: String
    var activity: Int
    var goal: Int
    
    init(weight: Double, height: Double, age: Int, gender: String, activity: Int, goal: Int) {
        self.weight = weight
        self.height = height
        self.age = age
        self.gender = gender
        self.activity = activity
        self.goal = goal
    }
    
    func calculateBMR(gender: String, age: Int, weight: Double, height: Double) -> Double {
        var bmr: Double = 0
        
        if gender == "male" {
            bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        } else if gender == "female" {
            bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        }
        
        return bmr
    }

    func calculateTDEE(bmr: Double, activity: Int) -> Double {
        var activityLevel: Double
        if(activity == 0) {
            activityLevel = 1.2
        } else if(activity == 1) {
            activityLevel = 1.375
        } else if(activity == 2) {
            activityLevel = 1.55
        } else if(activity == 3) {
            activityLevel = 1.725
        } else if(activity == 4) {
            activityLevel = 1.9
        } else {
            activityLevel = 0
        }
        
        let tdee = bmr * activityLevel
        return tdee
    }

    func calculateProtein(calories: Double) -> Double {
        let proteinPercentage = 0.3 // 30% of calories should come from prot
        let proteinCalories = calories * proteinPercentage
        let protein = proteinCalories / 4.0 // 1 gram of protein provides 4 calories
        return protein
    }

    func calculateCarbs(calories: Double) -> Double {
        let carbPercentage = 0.5 // 50% of calories should come from carbs
        let carbCalories = calories * carbPercentage
        let carbGrams = carbCalories / 4.0 // 1 gram of carbs provides 4 calories
        return carbGrams
    }


    func calculateFat(totalCalories: Double) -> Double {
        let fatPercentage = 0.2 // 20% din totalul caloriilor sa provina din grasimi
        let fatCalories = totalCalories * fatPercentage
        let fatGrams = fatCalories / 9.0 // 1 gram de grasime are 9 calorii
        return fatGrams
    }
    
    func calculateCaloriesNeeded(tdee: Double, goal: Int) -> Double {
        var caloriesNeeded: Double = 0
        
        if(goal == 0) {
            caloriesNeeded = tdee
        } else if (goal == 1) {
            caloriesNeeded = tdee * 0.8 // deficit de 20%
            
        } else if (goal == 2) {
            caloriesNeeded = tdee * 1.2
        }
        
        return caloriesNeeded
    }

    func calculateProtein(calories: Double, proteinPercentage: Double) -> Double {
        let proteinCalories = calories * proteinPercentage
        let protein = proteinCalories / 4.0 // 1 gram of carbs provides 4 calories
        return protein
    }

    func calculateCarbs(calories: Double, carbPercentage: Double) -> Double {
        let carbCalories = calories * carbPercentage
        let carbGrams = carbCalories / 4.0 // 1 gram of carbs provides 4 calories
        return carbGrams
    }

    func calculateFat(totalCalories: Double, fatPercentage: Double) -> Double {
        let fatCalories = totalCalories * fatPercentage
        let fatGrams = fatCalories / 9.0 // 1 gram of fat provides 9 calories
        return fatGrams
    }


    
}
