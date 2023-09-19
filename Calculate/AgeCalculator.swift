import Foundation

class AgeCalculator {
    var date: Date
    
    init(date: Date) {
        self.date = date
    }
    
    func calculateAge(date: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        guard let age = ageComponents.year else { return 0 }
        return age
    }

}
