class FoodCalculator {
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let fatsPer100g: Double
    let carbsPer100g: Double

    init(caloriesPer100g: Double, proteinPer100g: Double, fatsPer100g: Double, carbsPer100g: Double) {
        self.caloriesPer100g = caloriesPer100g
        self.proteinPer100g = proteinPer100g
        self.fatsPer100g = fatsPer100g
        self.carbsPer100g = carbsPer100g
    }

    func calculateCalories(for quantity: Double, initialQuantity: Double) -> Double {
        let calories = (caloriesPer100g / initialQuantity) * quantity
        return calories
    }

    func calculateProtein(for quantity: Double, initialQuantity: Double) -> Double {
        let protein = (proteinPer100g / initialQuantity) * quantity
        return protein
    }

    func calculateFats(for quantity: Double, initialQuantity: Double) -> Double {
        let fats = (fatsPer100g / initialQuantity) * quantity
        return fats
    }

    func calculateCarbs(for quantity: Double, initialQuantity: Double) -> Double {
        let carbs = (carbsPer100g / initialQuantity) * quantity
        return carbs
    }
}
