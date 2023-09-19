import UIKit
import SwiftyPickerPopover

class AdminReviewFood: UITableViewController, AddBarcodeVCDelegate{
    
    @IBOutlet var unitLabel: UILabel!
    
    @IBOutlet var nameTF: UITextField!
    
    @IBOutlet var brandTF: UITextField!
    
    @IBOutlet var servingsizeTF: UITextField!
    
    @IBOutlet var caloriesTF: UITextField!
    
    @IBOutlet var proteinsTF: UITextField!
    
    @IBOutlet var carbsTF: UITextField!
    @IBOutlet var fatsTF: UITextField!
    
    @IBOutlet var barcode: UILabel!
    
    @IBOutlet var declineFood: UIButton!
    @IBOutlet var saveFood: UIButton!
    var isDeclineButtonHidden = false
    var isSaveButtonHidden = false
    var isModifyButtonHidden = false
    @IBOutlet var modifyFood: UIButton!
    var foodId: Int = 0
    weak var delegate: AddBarcodeVCDelegate!
    var dbFood = DBManagerFood()
    var bc:String = ""
    var selectedRow: Int = 0
    var foodData: (String, String, Double, Double, Double, Double, Double, String, String)?
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Ascunde tastatura când se apasă tasta Enter
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        declineFood.isHidden = isDeclineButtonHidden
        saveFood.isHidden = isSaveButtonHidden
        modifyFood.isHidden = isModifyButtonHidden
        servingsizeTF.keyboardType = .decimalPad
        caloriesTF.keyboardType = .decimalPad
        fatsTF.keyboardType = .decimalPad
        proteinsTF.keyboardType = .decimalPad
        carbsTF.keyboardType = .decimalPad
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        if let nameTF = nameTF {
            let attributedPlaceholder = NSAttributedString(
                string: "name",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            nameTF.attributedPlaceholder = attributedPlaceholder
        }

        if let brandTF = brandTF {
            let attributedPlaceholder = NSAttributedString(
                string: "brand",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            brandTF.attributedPlaceholder = attributedPlaceholder
        }
        
        if let servingsizeTF = servingsizeTF {
            let attributedPlaceholder = NSAttributedString(
                string: "serving size",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            servingsizeTF.attributedPlaceholder = attributedPlaceholder
        }

        if let caloriesTF = caloriesTF {
            let attributedPlaceholder = NSAttributedString(
                string: "calories",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            caloriesTF.attributedPlaceholder = attributedPlaceholder
        }
        
        if let fatsTF = fatsTF {
            let attributedPlaceholder = NSAttributedString(
                string: "fats",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            fatsTF.attributedPlaceholder = attributedPlaceholder
        }
        
        if let carbsTF = carbsTF {
            let attributedPlaceholder = NSAttributedString(
                string: "carbs",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            carbsTF.attributedPlaceholder = attributedPlaceholder
        }
        
        if let proteinsTF = proteinsTF {
            let attributedPlaceholder = NSAttributedString(
                string: "proteins",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            proteinsTF.attributedPlaceholder = attributedPlaceholder
        }
        
        if let foodData = dbFood.getFoodForId(for: foodId) {
            self.foodData = foodData
            nameTF.text = foodData.0
            brandTF.text = foodData.1
            servingsizeTF.text = "\(foodData.2)"
            caloriesTF.text = "\(foodData.3)"
            proteinsTF.text = "\(foodData.4)"
            carbsTF.text = "\(foodData.6)"
            fatsTF.text = "\(foodData.5)"
            barcode.text = foodData.7
            unitLabel.text = foodData.8
            if(foodData.8 == "g") {
                selectedRow = 0
                unitLabel.text = "grams"
            } else {
                selectedRow = 1
                unitLabel.text = "milliliters"
            }
        }
    }
    
    
    @IBAction func changeUnit(_ sender: Any) {
        guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
            fatalError("Couldn't load LobsterTwo-Bold font")
        }
       
        let displayStringFor:((String?)->String?)? = { string in
            if let s = string {
                switch(s){
                case "value 1":
                    return "grams"
                case "value 2":
                    return "milliliters"
                default:
                    return "grams"
                    }
                }
                return nil
            }
                
            let p = StringPickerPopover(title: "Select a range", choices: ["value 1","value 2"])
                .setDisplayStringFor(displayStringFor)
                .setValueChange(action: { _, _, selectedString in
                        
                })
                
                .setDoneButton(
                    font: lobsterTwoFont,
                    action: { popover, selectedRow, selectedString in
                        print("done row \(selectedRow) \(selectedString)")
                       
                        if(selectedRow == 0) {
                            self.unitLabel.text = "grams"
                        }
                        if(selectedRow == 1) {
                            self.unitLabel.text = "milliliters"
                            
                        }
                        
                            
                    })
                    .setCancelButton(font:lobsterTwoFont,
                                     action: {_, _, _ in
                         })
                .setSelectedRow(selectedRow)
        p.appear(originView: sender as! UIView, baseViewController: self)
    }
    
    
    @IBAction func scanBC(_ sender: Any) {
        let newViewController = AddBarcodeVC()
        newViewController.delegate = self
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func didScanBarcode(value: String) {
           // Actualizarea valorii în view controller-ul precedent
            barcode.text = value
            self.bc = value
       }
    
    @IBAction func declineButton(_ sender: Any) {
        var unit = ""
        if(selectedRow == 0) {
            unit = "g"
        } else {
            unit = "ml"
        }
        dbFood.updateFood(for: foodId, name: nameTF.text!, brand: brandTF.text!, servingSize: Double(servingsizeTF.text!)!, unit: unit, calories: Double(caloriesTF.text!)!, protein: Double(proteinsTF.text!)!, fats: Double(fatsTF.text!)!, carbs: Double(carbsTF.text!)!, barcode: barcode.text!, isVisible: false, review: true)
    }
    
    
    @IBAction func acceptButton(_ sender: Any) {
        var unit = ""
        if(selectedRow == 0) {
            unit = "g"
        } else {
            unit = "ml"
        }
        dbFood.updateFood(for: foodId, name: nameTF.text!, brand: brandTF.text!, servingSize: Double(servingsizeTF.text!)!, unit: unit, calories: Double(caloriesTF.text!)!, protein: Double(proteinsTF.text!)!, fats: Double(fatsTF.text!)!, carbs: Double(carbsTF.text!)!, barcode: barcode.text!, isVisible: true, review: true)
    }
    
    @IBAction func modifyButton(_ sender: Any) {
        var unit = ""
        if(selectedRow == 0) {
            unit = "g"
        } else {
            unit = "ml"
        }
        dbFood.updateFood(for: foodId, name: nameTF.text!, brand: brandTF.text!, servingSize: Double(servingsizeTF.text!)!, unit: unit, calories: Double(caloriesTF.text!)!, protein: Double(proteinsTF.text!)!, fats: Double(fatsTF.text!)!, carbs: Double(carbsTF.text!)!, barcode: barcode.text!, isVisible: true, review: true)


    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToApproved" {
            if let tabBarController = segue.destination as? UITabBarController {
                tabBarController.selectedIndex = 2
                tabBarController.modalPresentationStyle = .fullScreen

            }
        }
        
        if segue.identifier == "backToPending2" {
            if let tabBarController = segue.destination as? UITabBarController {
                tabBarController.selectedIndex = 1
                tabBarController.modalPresentationStyle = .fullScreen

            }
        }
        
        if segue.identifier == "backToPending1" {
            if let tabBarController = segue.destination as? UITabBarController {
                tabBarController.selectedIndex = 1
                tabBarController.modalPresentationStyle = .fullScreen

            }
        }
    }
}
