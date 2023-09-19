import UIKit

class AdminPendingVC: UITableViewController, UISearchBarDelegate {

    var dbFood = DBManagerFood()
    var foods: [(String, String, String)] = []
    var filteredFoods: [(String, String, String)] = []
    
    
    @IBOutlet var searchBar: UISearchBar!
    
    
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
        let extractedFoods = dbFood.pending()
        
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

    
    // Implementează metodele pentru UISearchBar
    
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredFoods.isEmpty {
            // Dacă lista de alimente filtrate este goală, afișează o singură celulă cu mesajul
            return 1
        } else {
            return filteredFoods.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filteredFoods.isEmpty {
            // Dacă lista de alimente filtrate este goală, afișează celula cu mesajul
            let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCellPending", for: indexPath)
            cell.textLabel?.text = "All foods have been verified."
            cell.textLabel?.textColor = UIColor(red: 213/255, green: 125/255, blue: 149/255, alpha: 1.0)
            cell.textLabel?.font = UIFont(name: "LobsterTwo", size: 20)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCellPending", for: indexPath)
            let food = filteredFoods[indexPath.row]
            let cellText = "\(food.0) - \(food.1), \(food.2)"
            cell.textLabel?.text = cellText
            cell.textLabel?.textColor = UIColor(red: 213/255, green: 125/255, blue: 149/255, alpha: 1.0)
            cell.textLabel?.font = UIFont(name: "LobsterTwo", size: 20)
            return cell
        }
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

            

            let id = dbFood.getFoodIdByNameAndCreatedBy(name: name, brand: brand, createdBy: created_by)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tableViewController = storyboard.instantiateViewController(withIdentifier: "reviewFood") as? AdminReviewFood {
                tableViewController.modalPresentationStyle = .fullScreen
                tableViewController.foodId = id!
                tableViewController.isDeclineButtonHidden = false
                tableViewController.isSaveButtonHidden = false
                tableViewController.isModifyButtonHidden = true
                self.present(tableViewController, animated: true, completion: nil)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

}
