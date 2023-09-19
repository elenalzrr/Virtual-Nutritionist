import UIKit

class AdminApprovedVC: UITableViewController, UISearchBarDelegate {

    var dbFood = DBManagerFood()
    var foods: [(String, String, String)] = []
    var filteredFoods: [(String, String, String)] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        loadRandomFoods()
        tableView.reloadData()
    }
    
    func loadRandomFoods() {
        foods = generateRandomFoods(count: 20)
        filteredFoods = foods
    }
    
    func generateRandomFoods(count: Int) -> [(String, String, String)] {
        let extractedFoods = dbFood.approved()
        
        // Verifică dacă există suficiente alimente în baza de date
        guard !extractedFoods.isEmpty else {
            print("Nu există alimente aprobate în baza de date.")
            return []
        }
        
        // Extrage aleatoriu alimente
        let randomCount = min(count, extractedFoods.count)
        let randomFoods = Array(extractedFoods.shuffled().prefix(randomCount))
        
        return randomFoods
    }

    
    // Implementează metodele pentru UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFoods.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCellApproved", for: indexPath)
        let food = filteredFoods[indexPath.row]
        let cellText = "\(food.0) - \(food.1), \(food.2)"
        cell.textLabel?.text = cellText
        cell.textLabel?.textColor = UIColor(red: 213/255, green: 125/255, blue: 149/255, alpha: 1.0)
        cell.textLabel?.font = UIFont(name: "LobsterTwo", size: 20)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let info = cell.textLabel?.text

            let components = info!.components(separatedBy: "-")

            guard components.count >= 2 else {
                fatalError("Stringul nu are suficiente componente.")
            }

            let name = components[0].trimmingCharacters(in: .whitespaces)
            let restul = components[1]

            let restulComponents = restul.components(separatedBy: ",")

            guard restulComponents.count >= 2 else {
                fatalError("Restul informațiilor nu are suficiente componente.")
            }

            let brand = restulComponents[0].trimmingCharacters(in: .whitespaces)
            let created_by = restulComponents[1].trimmingCharacters(in: .whitespaces)


            let foodid = dbFood.getFoodIdByNameAndCreatedBy(name: name, brand: brand, createdBy: created_by)

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tableViewController = storyboard.instantiateViewController(withIdentifier: "reviewFood") as? AdminReviewFood {
                tableViewController.modalPresentationStyle = .fullScreen
                tableViewController.foodId = foodid!
                tableViewController.isDeclineButtonHidden = true
                tableViewController.isSaveButtonHidden = true
                tableViewController.isModifyButtonHidden = false
                self.present(tableViewController, animated: true, completion: nil)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredFoods = foods
        } else {
            filteredFoods = foods.filter { food in
                let name = food.0.lowercased()
                let brand = food.1.lowercased()
                let searchString = searchText.lowercased()
                
                return name.hasPrefix(searchString) || brand.hasPrefix(searchString)
            }
        }
        
        tableView.reloadData()
    }
}
