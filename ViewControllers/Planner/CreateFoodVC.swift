import Foundation
import AVFoundation
import SwiftyPickerPopover
import UIKit
import Toast

class CreateFoodVC: UITableViewController, AddBarcodeVCDelegate, UITextFieldDelegate {
    
    @IBOutlet var unitLabel: UILabel!
    
    @IBOutlet var nameTF: UITextField!
    
    @IBOutlet var brandTF: UITextField!
    
    @IBOutlet var servingsizeTF: UITextField!
    
    @IBOutlet var caloriesTF: UITextField!
    
    
    @IBOutlet var fatsTF: UITextField!
    
    
    @IBOutlet var proteinsTF: UITextField!
    
    @IBOutlet var carbsTF: UITextField!
    
    @IBOutlet var barcodeString: UILabel!
    weak var delegate: AddBarcodeVCDelegate!
    var dbFood = DBManagerFood()
    var bc:String = ""
    var selectedRow: Int = 0
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        servingsizeTF.keyboardType = .decimalPad
        caloriesTF.keyboardType = .decimalPad
        fatsTF.keyboardType = .decimalPad
        proteinsTF.keyboardType = .decimalPad
        carbsTF.keyboardType = .decimalPad
        barcodeString.text = bc
        nameTF.delegate = self
        brandTF.delegate = self
        servingsizeTF.delegate = self
        caloriesTF.delegate = self
        fatsTF.delegate = self
        proteinsTF.delegate = self
        carbsTF.delegate = self

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
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Ascunde tastatura când se apasă tasta Enter
        return true
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

    @IBAction func scanBarcode(_ sender: Any) {
        let newViewController = AddBarcodeVC()
        newViewController.delegate = self
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func didScanBarcode(value: String) {
           // Actualizarea valorii în view controller-ul precedent
            barcodeString.text = value
            self.bc = value
       }
    
    var canInsertFood = false
    var unit = ""
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let dispatchGroup = DispatchGroup()
                var shouldPerformSegue = true
                guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
                    fatalError("Couldn't load LobsterTwo-Bold font")
                }
                
                if (identifier == "createFood") {
                    dispatchGroup.enter()
                    
                    let isEmpty = nameTF.text!.isEmpty || brandTF.text!.isEmpty || servingsizeTF.text!.isEmpty ||
                        fatsTF.text!.isEmpty || carbsTF.text!.isEmpty || proteinsTF.text!.isEmpty || caloriesTF.text!.isEmpty
                    
                    if isEmpty {
                        shouldPerformSegue = false
                        let title =  "Please fill in all the required fields."
                        var style = ToastStyle()
                        style.messageColor = .white
                        style.backgroundColor = UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0)
                        style.titleFont = lobsterTwoFont
                        style.messageFont = lobsterTwoFont
                        self.view.makeToast(title, duration: 2.0, position: .top, style: style)
                        ToastManager.shared.isTapToDismissEnabled = true
                        ToastManager.shared.isQueueEnabled = true
                        dispatchGroup.leave() // Adăugat aici
                    } else {
                        dispatchGroup.enter()
                        
                        if dbFood.checkBarcodeExists(barcode: bc) {
                            shouldPerformSegue = false
                            let title =  "The barcode for this food item already exists."
                            var style = ToastStyle()
                            style.messageColor = .white
                            style.backgroundColor = UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0)
                            style.titleFont = lobsterTwoFont
                            style.messageFont = lobsterTwoFont
                            self.view.makeToast(title, duration: 2.0, position: .top, style: style)
                            ToastManager.shared.isTapToDismissEnabled = true
                            ToastManager.shared.isQueueEnabled = true
                            dispatchGroup.leave() // Adăugat aici
                        }
                        
                        dispatchGroup.leave()
                    }
            
            if(shouldPerformSegue == true) {

                let title =  "The food has been saved."
                // create a new style
                var style = ToastStyle()

                // this is just one of many style options
                style.messageColor = .white
                style.backgroundColor = UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0)
                style.titleFont = lobsterTwoFont
                style.messageFont = lobsterTwoFont
                // present the toast with the new style
                self.view.makeToast(title, duration: 2.0, position: .top, style: style)


                if(selectedRow == 0) {
                    unit = "g"
                }

                if(selectedRow == 1) {
                    unit = "ml"
                }

                // toggle "tap to dismiss" functionality
                ToastManager.shared.isTapToDismissEnabled = true

                // toggle queueing behavior
                ToastManager.shared.isQueueEnabled = true
                
                print("intra aici")
//                if (SingletonUser.shared.username == "admin"){
//                    dbFood.insert(name: nameTF.text!, brand: brandTF.text!, servingSize: Double(servingsizeTF.text!)!, unit: unit, calories: Double(caloriesTF.text!)!, protein: Double(proteinsTF.text!)!, fats: Double(fatsTF.text!)!, carbs: Double(carbsTF.text!)!, barcode: bc, isVisible: true, createdBy: SingletonUser.shared.username, date: Date(), review: true)
//
//                } else {
//                    dbFood.insert(name: nameTF.text!, brand: brandTF.text!, servingSize: Double(servingsizeTF.text!)!, unit: unit, calories: Double(caloriesTF.text!)!, protein: Double(proteinsTF.text!)!, fats: Double(fatsTF.text!)!, carbs: Double(carbsTF.text!)!, barcode: bc, isVisible: false, createdBy: SingletonUser.shared.username, date: Date(), review: false)
//                }
                canInsertFood = true
            }
        }
        
        return shouldPerformSegue
    }
    

    
    @IBAction func createFood(_ sender: Any) {
        if shouldPerformSegue(withIdentifier: "createFood", sender: self) {
                if SingletonUser.shared.username == "admin" {
                    self.performSegue(withIdentifier: "saveAdminCreate", sender: self)
                    dbFood.insert(name: nameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines), brand: brandTF.text!.trimmingCharacters(in: .whitespacesAndNewlines), servingSize: Double(servingsizeTF.text!.replacingOccurrences(of: ",", with: "."))!, unit: unit, calories: Double(caloriesTF.text!.replacingOccurrences(of: ",", with: "."))!, protein: Double(proteinsTF.text!.replacingOccurrences(of: ",", with: "."))!, fats: Double(fatsTF.text!.replacingOccurrences(of: ",", with: "."))!, carbs: Double(carbsTF.text!.replacingOccurrences(of: ",", with: "."))!, barcode: bc, isVisible: true, createdBy: SingletonUser.shared.username, date: Date(), review: true)
                    canInsertFood = false
                } else {
                    self.performSegue(withIdentifier: "createFood", sender: self)
                    dbFood.insert(name: nameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines), brand: brandTF.text!.trimmingCharacters(in: .whitespacesAndNewlines), servingSize: Double(servingsizeTF.text!.replacingOccurrences(of: ",", with: "."))!, unit: unit, calories: Double(caloriesTF.text!.replacingOccurrences(of: ",", with: "."))!, protein: Double(proteinsTF.text!.replacingOccurrences(of: ",", with: "."))!, fats: Double(fatsTF.text!.replacingOccurrences(of: ",", with: "."))!, carbs: Double(carbsTF.text!.replacingOccurrences(of: ",", with: "."))!, barcode: bc, isVisible: false, createdBy: SingletonUser.shared.username, date: Date(), review: false)
                    canInsertFood = false
                }
            }
    }
    
    @IBAction func backFood(_ sender: Any) {
        if(SingletonUser.shared.username == "admin") {
            self.performSegue(withIdentifier: "backAdminCreate", sender: self)
        } else {
            self.performSegue(withIdentifier: "backUserCreate", sender: self)
        }
    }
    
}

