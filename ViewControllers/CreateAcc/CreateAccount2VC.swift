import UIKit

class CreateAccount2VC: UIViewController{
    
    @IBOutlet var heightTF: UITextField!
    @IBOutlet var weightTF: UITextField!
    
    @IBOutlet var goalweightTF: UITextField!
    
    @IBOutlet var genderSC: UISegmentedControl!
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var calendar: UIDatePicker!
    var nameTF: String = ""
    var mailTF: String = ""
    var usernameTF: String = ""
    var passwordTF: String = ""
    @IBOutlet var weightErr: UILabel!
    
    @IBOutlet var goalweightErr: UILabel!
    @IBOutlet var heightErr: UILabel!
    
    var birthday: Date?
    
    
    
    func initColor() {
        if genderSC != nil {
            genderSC.setTitleTextAttributes([.foregroundColor: UIColor(rgb: 0x3375B1)], for: .selected)
            genderSC.setTitleTextAttributes([.foregroundColor: UIColor(rgb: 0xD78397)], for: .normal)
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        initColor()
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        heightTF.keyboardType = .numberPad
        weightTF.keyboardType = .decimalPad
        goalweightTF.keyboardType = .decimalPad
        
        if let weightTF = weightTF {
            weightTF.delegate = self
        }
        
        if let heightTF = heightTF {
            heightTF.delegate = self
        }
        
        if let goalweightTF = goalweightTF {
            goalweightTF.delegate = self
        }
        let defaults = UserDefaults.standard
        

        let retrievedSegmentIndex = UserDefaults.standard.integer(forKey: "selectedSegmentIndex")
        genderSC.selectedSegmentIndex = retrievedSegmentIndex
        
        if let weight = defaults.string(forKey: "weight") {
            weightTF.text = weight
         }
        if let selectedDate = UserDefaults.standard.object(forKey: "selectedDate") as? Date {
            calendar.setDate(selectedDate, animated: true)
        }

        if let height = defaults.string(forKey: "height") {
            heightTF.text = height
         }
        
        if let goalweight = defaults.string(forKey: "goalweight") {
            goalweightTF.text = goalweight
         }
        if let weightTF = weightTF {
            let attributedPlaceholder = NSAttributedString(
                string: "kg",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            weightTF.attributedPlaceholder = attributedPlaceholder
        }

        if let goalweightTF = goalweightTF {
            let attributedPlaceholder = NSAttributedString(
                string: "kg",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            goalweightTF.attributedPlaceholder = attributedPlaceholder
        }
        if let heightTF = heightTF {
            let attributedPlaceholder = NSAttributedString(
                string: "cm",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            heightTF.attributedPlaceholder = attributedPlaceholder
        }
        
    }
    

    @IBAction func changeGenderColor(_ sender: UISegmentedControl) {
        if genderSC.selectedSegmentIndex == 1 {
            genderSC.setTitleTextAttributes([.foregroundColor: UIColor(rgb: 0x3375B1)], for: .normal)
            genderSC.setTitleTextAttributes([.foregroundColor: UIColor(rgb: 0xD78397)], for: .selected)
        } else {
            genderSC.setTitleTextAttributes([.foregroundColor: UIColor(rgb: 0x3375B1)], for: .selected)
            genderSC.setTitleTextAttributes([.foregroundColor: UIColor(rgb: 0xD78397)], for: .normal)
        }
        
    }
    @IBAction func action(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(genderSC.selectedSegmentIndex, forKey: "selectedSegmentIndex")
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let dispatchGroup = DispatchGroup()
        var shouldPerformSegue = true
        if identifier == "2to3" {
            dispatchGroup.enter()
            if(weightTF.text!.count == 0) {
                weightErr.text = "This field is required"
                weightErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if(weightTF.text!.count == 1 || Double(weightTF.text!.replacingOccurrences(of: ",", with: "."))! > 200 || Double(weightTF.text!.replacingOccurrences(of: ",", with: "."))! < 30 ) {
                weightErr.text = "Invalid weight"
                weightErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else {
                weightErr.isHidden = true
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            if(heightTF.text!.count == 0) {
                heightErr.text = "This field is required"
                heightErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if(heightTF.text!.count == 1 || heightTF.text!.count == 2 || heightTF.text!.count > 3 || Double(heightTF.text!)! < 140) {
                heightErr.text = "Invalid height"
                heightErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else {
                heightErr.isHidden = true
                dispatchGroup.leave()
            }
            dispatchGroup.enter()
            if(goalweightTF.text!.count == 0) {
                goalweightErr.text = "This field is required"
                goalweightErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if(goalweightTF.text!.count == 1 || Double(goalweightTF.text!.replacingOccurrences(of: ",", with: "."))! > 200) {
                goalweightErr.text = "Invalid weight"
                goalweightErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if(Double(goalweightTF.text!.replacingOccurrences(of: ",", with: "."))! < 40){
                goalweightErr.text = "Unhealthy goal weight"
                goalweightErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else {
                goalweightErr.isHidden = true
                dispatchGroup.leave()
            }
        }
        return shouldPerformSegue
        
    }
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        UserDefaults.standard.set(sender.date, forKey: "selectedDate")
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "2to3" {
            if let destinationVC = segue.destination as? CreateAccount3VC {
                destinationVC.nameTF = nameTF
                destinationVC.mailTF = mailTF
                destinationVC.usernameTF = usernameTF
                destinationVC.passwordTF = passwordTF
                destinationVC.birthday = datePicker.date
                destinationVC.heightTF = heightTF.text!
                destinationVC.weightTF = weightTF.text!
                if(genderSC.selectedSegmentIndex == 0) {
                    destinationVC.gender = "male"
                } else {
                    destinationVC.gender = "female"
                }
                destinationVC.goalweightTF = goalweightTF.text!
            }
        }
    }
}

extension UIColor {
    
    convenience init(rgb: UInt) {
        self.init(rgb: rgb, alpha: 1.0)
    }
    
    convenience init(rgb: UInt, alpha: CGFloat) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
}
extension CreateAccount2VC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""

        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        let range = NSRange(location: 0, length: newText.utf16.count)
        
        if(textField.restorationIdentifier == "weight") {
            let regex = try! NSRegularExpression(pattern: "^\\d{0,3}(\\,\\d{0,2})?$")
            if regex.firstMatch(in: newText, options: [], range: range) == nil {
                return false
            }
            return true
        }
        if(textField.restorationIdentifier == "height") {
            let regex = try! NSRegularExpression(pattern: "^\\d{0,3}?$")
            if regex.firstMatch(in: newText, options: [], range: range) == nil {
                return false
            }
            return true
        }
        
        if(textField.restorationIdentifier == "goalweight") {
            let regex = try! NSRegularExpression(pattern: "^\\d{0,3}(\\,\\d{0,2})?$")
            if regex.firstMatch(in: newText, options: [], range: range) == nil {
                return false
            }
            return true
        }
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
            let defaults = UserDefaults.standard
            if textField == weightTF {
                defaults.set(weightTF.text, forKey: "weight")
            } else if textField == heightTF {
                defaults.set(heightTF.text, forKey: "height")
            } else if textField == goalweightTF {
                defaults.set(goalweightTF.text, forKey: "goalweight")
            }
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      return true
    }

}
