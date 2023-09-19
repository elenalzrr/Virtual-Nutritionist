import UIKit
import SwiftyPickerPopover
class ProgressAddVC: UITableViewController, UITextFieldDelegate {

    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var weightTF: UITextField!
    @IBOutlet var dateChanger: UIButton!
    var userId: Int = 0
    
    var dbProgress = DBManagerProgress()
    var dbUser = DBManagerUser()
    var selDate: Date!
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        weightTF.delegate = self
        userId = SingletonUser.shared.userId
        selDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: Date())
        dateLabel.text = dateString
        
        weightTF.keyboardType = .decimalPad
        
        let lastweight = dbProgress.getWeightsForUser(user_id: userId).map({ $0.0 }).reversed().first!
        let weightString = String(lastweight)
        let placeholderText = weightString
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)]
        weightTF.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        weightTF.text = weightString
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveprog" {
            if(weightTF.text!.contains(",")) {
                let weight = weightTF.text!.replacingOccurrences(of: ",", with: ".")
                dbProgress.insertOrUpdateProgress(user_id: userId, date: selDate, weight: Double(weight)!)
    
            } else {
                dbProgress.insertOrUpdateProgress(user_id: userId, date: selDate, weight: Double(weightTF.text!)!)
            }
        }
    }


    
    @IBAction func changeDate(_ sender: Any) {
        guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
            fatalError("Couldn't load LobsterTwo-Bold font")
        }

        DatePickerPopover(title: "Date")
                    .setDateMode(.date)
                    .setSelectedDate(Date())
                    .setMaximumDate(Date())
                    .setValueChange(action: { _, selectedDate in

                    })
                    .setDoneButton(title:"Save", font:lobsterTwoFont, color:UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),action: { popover, selectedDate in
                        self.selDate = selectedDate
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        let dateString = dateFormatter.string(from: selectedDate)
                        self.dateLabel.text = dateString
                        
                    })
                    .setCancelButton(title:"Cancel", font:lobsterTwoFont, color:UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),action: { _, _ in print("cancel")})
                    .appear(originView: sender as! UIView, baseViewController: self)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = "" // șterge textul din textfield
    }

}
