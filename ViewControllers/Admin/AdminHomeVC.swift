import UIKit
import PMAlertController
class AdminHomeVC: UITableViewController {
    var newsEntries: [String] = []
    var dbFood = DBManagerFood()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNewsEntries()
        print(SingletonUser.shared.username)
    }
    
    func loadNewsEntries() {
        let entries = dbFood.news()
        newsEntries = entries.map { "\($0.0) created \($0.1), \($0.2)" }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if newsEntries.isEmpty {
            return 1
        } else {
            return min(newsEntries.count, 10)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          if newsEntries.isEmpty {
              let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
              cell.textLabel?.text = "No news"
              cell.textLabel?.textColor = UIColor(red: 213/255, green: 125/255, blue: 149/255, alpha: 1.0)
              cell.textLabel?.font = UIFont(name: "LobsterTwo", size: 20)
              return cell
          } else {
              let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
              let entry = newsEntries[indexPath.row]
              cell.textLabel?.text = entry
              cell.textLabel?.textColor = UIColor(red: 213/255, green: 125/255, blue: 149/255, alpha: 1.0)
              cell.textLabel?.font = UIFont(name: "LobsterTwo", size: 20)
              return cell
          }
      }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "News"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }

        headerView.textLabel?.font = UIFont(name: "LobsterTwo", size: 20)
        headerView.textLabel?.textColor = UIColor(red: 213/255, green: 125/255, blue: 149/255, alpha: 1.0)
        headerView.textLabel?.lineBreakMode = .byWordWrapping

    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "logoutAdmin" {
            let alertVC = PMAlertController(title: "Logout", description: "Are you sure you want to log out?", image: nil, style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: nil))
            
            alertVC.addAction(PMAlertAction(title: "Logout", style: .default, action: { [weak self] in
                guard let self = self else { return }
                self.performSegue(withIdentifier: identifier, sender: sender)
            }))


            self.present(alertVC, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }


}
