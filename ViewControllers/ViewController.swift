import UIKit
import HealthKit

class ViewController: UIViewController {

    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldUsername: UITextField!

    @IBOutlet var loginButton: UIButton!
    var dbUser = DBManagerUser()
    var dbFood = DBManagerFood()
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    func insertFood() {
        dbFood.insert(name: "Piept de pui", brand: "Lidl", servingSize: 100, unit: "g", calories: 105, protein: 22, fats: 1, carbs: 0, barcode: "", isVisible: true, createdBy: "admin", date: Date(), review: true)
        

        dbFood.insert(name: "Ton al naturale", brand: "Rio Mare", servingSize: 100, unit: "g", calories: 100.5, protein: 24, fats: 0.5, carbs: 0, barcode: "", isVisible: true, createdBy: "admin", date: Date(), review: true)

        dbFood.insert(name: "Cartofi albi", brand: "Gradina", servingSize: 100,unit: "g",  calories: 69, protein: 1.68, fats: 0.1, carbs: 15.71, barcode: "", isVisible: true, createdBy: "admin", date: Date(), review: true)
        
        dbFood.insert(name: "Iaurt", brand: "Zuzu stors 2%", servingSize: 100,unit: "g",  calories: 61, protein: 8, fats: 2, carbs: 2.68, barcode: "", isVisible: true, createdBy: "admin", date: Date(), review: true)
        
        dbFood.insert(name: "Bautura carbogazoasa", brand: "Sprite", servingSize: 100,unit: "ml",  calories: 9, protein: 0, fats: 0, carbs: 2, barcode: "54491069", isVisible: true, createdBy: "admin", date: Date(), review: true)
        
        dbFood.insert(name: "Ciocolata cu Oreo", brand: "Milka", servingSize: 100,unit: "g",  calories: 548, protein: 5.6, fats: 33, carbs: 56, barcode: "", isVisible: true, createdBy: "admin", date: Date(), review: true)
        
        dbFood.insert(name: "Fulgi de ovaz", brand: "Crownfield (Lidl)", servingSize: 100,unit: "g",  calories: 372, protein: 13.5, fats: 7, carbs: 58.7, barcode: "", isVisible: true, createdBy: "admin", date: Date(), review: true)
        
        dbFood.insert(name: "Orez alb cu bob lung basmati", brand: "Carrefour Extra", servingSize: 100,unit: "g",  calories: 347, protein: 8.9, fats: 0.7, carbs: 75, barcode: "", isVisible: true, createdBy: "admin", date: Date(), review: true)
        
        dbFood.insert(name: "Pastrama de oaie condimentata", brand: "Lidl", servingSize: 100,unit: "g",  calories: 150, protein: 20, fats: 7.6, carbs: 0.8, barcode: "", isVisible: true, createdBy: "admin", date: Date(), review: true)
        
        dbFood.insert(name: "Biscuiti", brand: "Leibniz", servingSize: 100, unit: "g", calories: 435, protein: 8.4, fats: 12, carbs: 72, barcode: "5901414204709", isVisible: true, createdBy: "admin", date: Date(), review: true)
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // insertFood()

        
        initializeTextFields()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        if let textFieldUsername = textFieldUsername {
            let attributedPlaceholder = NSAttributedString(
                string: "Username",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            textFieldUsername.attributedPlaceholder = attributedPlaceholder
        }

        if let textFieldPassword = textFieldPassword {
            let attributedPlaceholder = NSAttributedString(
                string: "Password",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            textFieldPassword.attributedPlaceholder = attributedPlaceholder
        }
        

            
       
    }

    func initializeTextFields() {
        textFieldUsername.delegate = self
        textFieldPassword.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login" {
            let userId = dbUser.getUserIdByUsername(username: textFieldUsername.text!.lowercased())!
            SingletonUser.shared.userId = userId
            SingletonUser.shared.isLoggedIn = true
            SingletonUser.shared.username = textFieldUsername.text!.lowercased()
            }
    }
        
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "login" {
            if(dbUser.checkCredentials(username: textFieldUsername.text!.lowercased(), password: textFieldPassword.text!) == true) {
                return true
            } else {
                let backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                let textColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                let font = UIFont(name: "LobsterTwo", size: 18)
                let fontbold = UIFont(name: "LobsterTwo-Bold", size: 24)
                if(textFieldUsername.text!.count == 0 || textFieldPassword.text!.count == 0) {
                    let alertController = UIAlertController(title: "Empty credentials", message: "Please fill in all fields.", preferredStyle: .alert)
                    alertController.view.tintColor = textColor
                    alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = backgroundColor
                    
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    okAction.setValue(textColor, forKey: "titleTextColor")
                    
                    alertController.addAction(okAction)
                    alertController.setValue(NSAttributedString(string: "Empty credentials", attributes: [
                        NSAttributedString.Key.foregroundColor: textColor,
                        NSAttributedString.Key.font: fontbold!
                    ]), forKey: "attributedTitle")
                    alertController.setValue(NSAttributedString(string: "Please fill in all fields.", attributes: [
                        NSAttributedString.Key.foregroundColor: textColor,
                        NSAttributedString.Key.font: font!
                    ]), forKey: "attributedMessage")
                    
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Wrong credentials", message: "Invalid username or password.", preferredStyle: .alert)
                    alertController.view.tintColor = textColor
                    alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = backgroundColor
                    
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    okAction.setValue(textColor, forKey: "titleTextColor")
                    
                    alertController.addAction(okAction)
                    alertController.setValue(NSAttributedString(string: "Wrong credentials", attributes: [
                        NSAttributedString.Key.foregroundColor: textColor,
                        NSAttributedString.Key.font: fontbold!
                    ]), forKey: "attributedTitle")
                    alertController.setValue(NSAttributedString(string: "Invalid username or password.", attributes: [
                        NSAttributedString.Key.foregroundColor: textColor,
                        NSAttributedString.Key.font: font!
                    ]), forKey: "attributedMessage")
                    
                    self.present(alertController, animated: true, completion: nil)
                }

                return false
            }
        }
        
        if identifier == "register" {
            return true
        }
        return false
        
    }
    
    
    @IBAction func login(_ sender: Any) {
        if(textFieldUsername.text!.lowercased() == "admin" && textFieldPassword.text! == "admin"){
               performSegue(withIdentifier: "admin", sender: self)
            SingletonUser.shared.username = "admin"
           } else if(dbUser.checkCredentials(username: textFieldUsername.text!.lowercased(), password: textFieldPassword.text!) == true){
               performSegue(withIdentifier: "login", sender: self)
           }
    }
    

}

extension ViewController: UITextFieldDelegate {
    //Restrictionare numar de caractere
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        
        switch textField {
            
        case textFieldPassword:
            return newLength <= 20
            
        case textFieldUsername:
            return newLength <= 15
            
        default:
            return newLength <= 5
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      return true
    }

}
