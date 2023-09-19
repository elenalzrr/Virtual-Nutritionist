import UIKit

class SearchFoodVC: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
      
    
    @IBOutlet var mealName: UILabel!
    
    @IBOutlet var barcodeBtn: UIButton!
    
    @IBOutlet var foodBtn: UIButton!
    
    var food: [(String, String, Double, Double, Double, Double, Double)] = []
    var filteredData: [(String, String, Double, Double, Double, Double, Double)] = []
    var dbFood = DBManagerFood()
    var mealN: String = ""
    var foodId: Int = 0
    var dateAdded: Date!
    
    var selectedMealName: String?
    var selectedDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        

        food = dbFood.getFoodData(createdBy: SingletonUser.shared.username)! 

        mealName.text = mealN
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToPlanner" {
            if let tabBarController = segue.destination as? UITabBarController {
                tabBarController.selectedIndex = 1
                tabBarController.modalPresentationStyle = .fullScreen

            }
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Resetează bara de căutare și afișează primele 20 de elemente
            searchBar.text = nil
            filteredData.removeAll()
            tableView.reloadData()
        }
        // Continuă cu restul logicii pentru filtrarea datelor în funcția searchBarSearchButtonClicked(_:)
        if searchText.count >= 3 {
            filteredData = food.filter { element in
                let containsInFirst = element.0.lowercased().contains(searchText.lowercased())
                let containsInSecond = element.1.lowercased().contains(searchText.lowercased())
                return containsInFirst || containsInSecond
            }
            tableView.reloadData()
        }
    }


    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Returnează înălțimea dorită pentru celula de la indexPath specificat
        return 70 // Înălțimea dorită a celulei (în puncte)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if searchBar.text?.isEmpty ?? true {
            // Afisam primele 20 de elemente din arrayul food
            let maxRowCount = min(20, food.count)
            return maxRowCount
        } else {
            // Afisam numarul de randuri corespunzator filtrului de cautare
            return filteredData.count
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell", for: indexPath)
           
        
        if let foodCell = cell as? FoodTableViewCell {
            // Configurează outlet-ul nameLabel din foodCell
            if searchBar.text?.isEmpty ?? true {
                
                if(food[indexPath.row].1 != " - ") {
                    foodCell.nameLabel.text = food[indexPath.row].0 + " - " + food[indexPath.row].1
                } else {
                    foodCell.nameLabel.text = food[indexPath.row].0
                }
                
                let unit = dbFood.getUnitByNameAndBrand(name: food[indexPath.row].0, brand: food[indexPath.row].1)

                foodCell.caloriesLabel.text = String(food[indexPath.row].3) + " kcal, " + String(food[indexPath.row].2) + " " + unit!
            } else {
                if(filteredData[indexPath.row].1 != " - ") {
                    foodCell.nameLabel.text = filteredData[indexPath.row].0 + " - " + filteredData[indexPath.row].1
                } else {
                    foodCell.nameLabel.text = filteredData[indexPath.row].0
                }
                let unit = dbFood.getUnitByNameAndBrand(name: filteredData[indexPath.row].0, brand: filteredData[indexPath.row].1)
                foodCell.caloriesLabel.text = String(filteredData[indexPath.row].3) + " kcal, " + String(filteredData[indexPath.row].2) + " " + unit!
            }
        }
           return cell
       }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Verificați dacă celula selectată este celula dvs. de interes
        if let cell = tableView.cellForRow(at: indexPath) as? FoodTableViewCell {
            let mealName = cell.nameLabel.text
            

            var foodName: String?
            if let dashRange = mealName!.range(of: "-") {
                let startIndex = mealName!.startIndex
                let endIndex = dashRange.lowerBound
                foodName = String(mealName![startIndex..<endIndex].trimmingCharacters(in: .whitespaces))
            } else {
                foodName = mealName!.trimmingCharacters(in: .whitespaces)
            }

            var brandname: String?
            if let dashRange = mealName!.range(of: "-") {
                let startIndex = dashRange.upperBound
                let endIndex = mealName!.endIndex
                brandname = String(mealName![startIndex..<endIndex].trimmingCharacters(in: .whitespaces))
            } else {
                brandname = "-"
            }

            if(brandname != "-"){
                foodId = dbFood.getFoodIdByName(name: foodName!, brand: brandname!)!
            } else {
                foodId = dbFood.getFoodIdByName(name: foodName!, brand: "-")!
            }
                
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tableViewController = storyboard.instantiateViewController(withIdentifier: "AddFood") as? AddFoodVC {
                tableViewController.modalPresentationStyle = .fullScreen
                tableViewController.mealN = mealN
                tableViewController.foodId = foodId
                tableViewController.dateAdded = dateAdded
                self.present(tableViewController, animated: true, completion: nil)
            }
            

        }
        
        // Deselectați celula după ce a fost apăsată pentru a îndepărta evidența de selecție vizuală
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func searchBarcode(_ sender: Any) {
        let newViewController = BarcodeVC()
        self.present(newViewController, animated: true, completion: nil)

    }
    
    }
