import UIKit
import SwiftyPickerPopover
import SwiftUI

class ProgressVC: UITableViewController {
    
    var userId: Int = 0
    
    @IBOutlet var addButton: UIButton!
    var kg: [(String, String)] = []
    var dbProgress = DBManagerProgress()
    var dbUser = DBManagerUser()
    var selectedRow: Int = 0
    var progress_number: Int = 0
    @IBOutlet var changeTime: UIButton!
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var chartView: UIView!
    var childView = UIHostingController(rootView: ProgressChart())
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = SingletonUser.shared.userId
        tableView.separatorColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
        progress_number = dbProgress.getEntryCountForUser(user_id: userId)
        

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM yyyy"

        let weights = dbProgress.getWeightsForUser(user_id: userId)

        let sortedWeights = weights.sorted(by: { $0.1 > $1.1 })


        for weightEntry in sortedWeights {
            let weightString = "\(weightEntry.0) kg"
            let dateString = dateFormatter.string(from: weightEntry.1)
            
            kg.append((weightString, dateString))
        }


        childView = UIHostingController(rootView: ProgressChart(demoData: dbProgress.getWeightsForUser(user_id: userId).map { $0.0 }))
        addChild(childView)
        childView.view.frame = chartView.bounds
        childView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childView.view.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
        chartView.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
        chartView.addSubview(childView.view)
        childView.didMove(toParent: self)
        
        
        

        
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "progress" {
            if let tabBarController = segue.destination as? UITabBarController {
                tabBarController.selectedIndex = 2
                tabBarController.modalPresentationStyle = .fullScreen
            }
        }
    }
    
    override func tableView(_ tableView: UITableView,
            numberOfRowsInSection section: Int) -> Int {
        return kg.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "weight")
        cell.textLabel?.text = kg.map { $0.0 }[indexPath.row]
        cell.textLabel?.font = UIFont(name: "LobsterTwo", size: 28)
        cell.textLabel?.textColor = UIColor(red: 213/255, green: 125/255, blue: 149/255, alpha: 1.0)
        cell.detailTextLabel?.text = kg.map { $0.1 }[indexPath.row]
        cell.detailTextLabel?.font = UIFont(name: "LobsterTwo", size: 20)
        cell.detailTextLabel?.textColor = UIColor(red: 0.886, green: 0.639, blue: 0.702, alpha: 1.0)
        cell.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
        cell.selectedBackgroundView = selectedBackgroundView
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            let inputString = self!.kg.map{ $0.1}[indexPath.row]

            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "EEEE, dd MMMM yyyy"

            let date = inputFormatter.date(from: inputString)

            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd/MM/yyyy"

            let outputString = outputFormatter.string(from: date!)

            let outputDate = outputFormatter.date(from: outputString)
            self!.dbProgress.deleteProgressByUserIdAndDate(user_id: self!.userId, date: outputDate!)


 
            self!.childView.removeFromParent()
            self!.childView.view.removeFromSuperview()

            // Adaugă codul pentru ștergerea celulei din sursa de date
            if(self!.selectedRow == 0) {
                var data:[Double] = []
                data = self!.dbProgress.getWeightsForUser(user_id: self!.userId).map { $0.0 }
                self!.childView = UIHostingController(rootView: ProgressChart(demoData: data))

            }
            if(self!.selectedRow == 1) {
                var dataweek:[Double] = []
                dataweek = self!.getWeightsForLastWeek(user_id: self!.userId).map { $0.0 }
                self!.childView = UIHostingController(rootView: ProgressChart(demoData:dataweek))

            }
            if(self!.selectedRow == 2) {
                var datamonth:[Double] = []
                datamonth = (self?.getWeightsForLastMonth(user_id: self!.userId).map { $0.0 })!
                self!.childView = UIHostingController(rootView: ProgressChart(demoData: datamonth))
            }
            if(self!.selectedRow == 3) {
                var datayear:[Double] = []
                datayear = (self?.getWeightsForLastYear(user_id: self!.userId).map { $0.0 })!
                self!.childView = UIHostingController(rootView: ProgressChart(demoData: datayear))
            }
            self!.addChild(self!.childView)
            self!.childView.view.frame = self!.chartView.bounds
            self!.childView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self!.childView.view.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
            self!.chartView.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
            self!.chartView.addSubview(self!.childView.view)
            self!.childView.didMove(toParent: self)
            self?.kg.remove(at: indexPath.row)
            // Șterge celula din tabel


            tableView.deleteRows(at: [indexPath], with: .fade)


            completionHandler(true)
        }
        deleteAction.backgroundColor = UIColor(red: 0.886, green: 0.639, blue: 0.702, alpha: 1.0)
        deleteAction.image = UIImage(systemName: "trash.fill")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }


    func getWeightsForLastMonth(user_id: Int) -> [(Double, Date)] {
        let allWeights = dbProgress.getWeightsForUser(user_id: user_id)
        let currentDate = Date()
        let calendar = Calendar.current
        
        let lastMonthWeights = allWeights.filter { (weight, date) in
            let components = calendar.dateComponents([.month], from: date, to: currentDate)
            if let monthDifference = components.month {
                return monthDifference < 1
            }
            return false
        }
        
        return lastMonthWeights
    }
    func getWeightsForLastWeek(user_id: Int) -> [(Double, Date)] {
        let allWeights = dbProgress.getWeightsForUser(user_id: user_id)
        let currentDate = Date()
        let calendar = Calendar.current
        
        let lastWeekWeights = allWeights.filter { (weight, date) in
            let components = calendar.dateComponents([.day], from: date, to: currentDate)
            if let dayDifference = components.day {
                return dayDifference < 7
            }
            return false
        }
        
        return lastWeekWeights
    }
    func getWeightsForLastYear(user_id: Int) -> [(Double, Date)] {
        let allWeights = dbProgress.getWeightsForUser(user_id: user_id)
        let currentDate = Date()
        let calendar = Calendar.current
        
        let lastYearWeights = allWeights.filter { (weight, date) in
            let components = calendar.dateComponents([.year], from: date, to: currentDate)
            if let yearDifference = components.year {
                return yearDifference < 1
            }
            return false
        }
        
        return lastYearWeights
    }
    
    @IBAction func changeTimeAction(_ sender: Any) {
        
        guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
            fatalError("Couldn't load LobsterTwo-Bold font")
        }
       
        let displayStringFor:((String?)->String?)? = { string in
            if let s = string {
                switch(s){
                case "value 1":
                    return "All"
                case "value 2":
                    return "1 Week"
                case "value 3":
                    return "1 Month"
                case "value 4":
                    return "1 Year"
                default:
                    return s
                    }
                }
                return nil
            }
                
            let p = StringPickerPopover(title: "Select a range", choices: ["value 1","value 2","value 3","value 4"])
                .setDisplayStringFor(displayStringFor)
                .setValueChange(action: { _, _, selectedString in
                        
                })
                
                .setDoneButton(
                    font: lobsterTwoFont,
                    action: { popover, selectedRow, selectedString in
                        print("done row \(selectedRow) \(selectedString)")
                        self.selectedRow = Int(selectedRow)
                        self.childView.removeFromParent()
                        self.childView.view.removeFromSuperview()

                        if(selectedRow == 0) {
                            self.timeLabel.text = "All"
                            
                            var data:[Double] = []
                            data = self.dbProgress.getWeightsForUser(user_id: self.userId).map { $0.0 }
                            self.childView = UIHostingController(rootView: ProgressChart(demoData: data))
                            self.addChild(self.childView)
                            self.childView.view.frame = self.chartView.bounds
                            self.childView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                            self.childView.view.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                            self.chartView.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                            self.chartView.addSubview(self.childView.view)
                            self.childView.didMove(toParent: self)
                        }
                        if(selectedRow == 1) {
                            self.timeLabel.text = "1 Week"
                            var dataweek:[Double] = []
                            dataweek = self.getWeightsForLastWeek(user_id: self.userId).map { $0.0 }
                            self.childView = UIHostingController(rootView: ProgressChart(demoData:dataweek))
                            self.addChild(self.childView)
                            self.childView.view.frame = self.chartView.bounds
                            self.childView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                            self.childView.view.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                            self.chartView.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                            self.chartView.addSubview(self.childView.view)
                            self.childView.didMove(toParent: self)
                            
                        }
                        if(selectedRow == 2) {
                            self.timeLabel.text = "1 Month"
                            var datamonth:[Double] = []
                            datamonth = self.getWeightsForLastMonth(user_id: self.userId).map { $0.0 }
                            print(datamonth)
                            self.childView = UIHostingController(rootView: ProgressChart(demoData: datamonth))
                            self.addChild(self.childView)
                            self.childView.view.frame = self.chartView.bounds
                            self.childView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                            self.childView.view.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                            self.chartView.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                            self.chartView.addSubview(self.childView.view)
                            self.childView.didMove(toParent: self)
                        }
                        if(selectedRow == 3) {
                            self.timeLabel.text = "1 Year"
                            var datayear:[Double] = []
                            datayear = self.getWeightsForLastYear(user_id: self.userId).map { $0.0 }
                            self.childView = UIHostingController(rootView: ProgressChart(demoData: datayear))
                            self.addChild(self.childView)
                            self.childView.view.frame = self.chartView.bounds
                            self.childView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                            self.childView.view.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                            self.chartView.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                            self.chartView.addSubview(self.childView.view)
                            self.childView.didMove(toParent: self)
                        }
                            
                    })
                    .setCancelButton(font:lobsterTwoFont,
                                     action: {_, _, _ in
                         })
                .setSelectedRow(selectedRow)
        p.appear(originView: sender as! UIView, baseViewController: self)
        
    }
    
}
