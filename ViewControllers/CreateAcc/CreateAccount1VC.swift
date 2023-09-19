import UIKit
import SQLite3
import CryptoKit
class CreateAccount1VC: UIViewController{
    
    
    @IBOutlet var nameTF: UITextField!
    @IBOutlet var mailTF: UITextField!
    @IBOutlet var usernameTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var passwordConfirmTF: UITextField!
    
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var nameErr: UILabel!
    @IBOutlet var mailErr: UILabel!
    @IBOutlet var usernameErr: UILabel!
    @IBOutlet var passErr: UILabel!
    @IBOutlet var passCnfErr: UILabel!
    
    
    var dbUser = DBManagerUser()
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        passwordTF.textContentType = .oneTimeCode
        if let nameTF = nameTF {
            nameTF.delegate = self
        }
        if let mailTF = mailTF {
            mailTF.delegate = self
        }
        if let usernameTF = usernameTF {
            usernameTF.delegate = self
        }
        
        if let passwordTF = passwordTF {
            passwordTF.delegate = self
        }
        if let passwordConfirmTF = passwordConfirmTF {
            passwordConfirmTF.delegate = self
        }

        let defaults = UserDefaults.standard
        if let name = defaults.string(forKey: "name") {
             nameTF.text = name
         }
        
        if let username = defaults.string(forKey: "username") {
             usernameTF.text = username
         }
        
        if let mail = defaults.string(forKey: "mail") {
             mailTF.text = mail
         }
        if let nameTF = nameTF {
            let attributedPlaceholder = NSAttributedString(
                string: "What's your name?",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            nameTF.attributedPlaceholder = attributedPlaceholder
        }

        if let mailTF = mailTF {
            let attributedPlaceholder = NSAttributedString(
                string: "Enter your mail",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            mailTF.attributedPlaceholder = attributedPlaceholder
        }
        
        if let usernameTF = usernameTF {
            let attributedPlaceholder = NSAttributedString(
                string: "Choose your username",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            usernameTF.attributedPlaceholder = attributedPlaceholder
        }
        
        if let passwordTF = passwordTF {
            let attributedPlaceholder = NSAttributedString(
                string: "Password",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            passwordTF.attributedPlaceholder = attributedPlaceholder
        }
        
        if let passwordConfirmTF = passwordConfirmTF {
            let attributedPlaceholder = NSAttributedString(
                string: "Confirm Password",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0xE1/255, green: 0xA3/255, blue: 0xB3/255, alpha: 1)]
            )
            passwordConfirmTF.attributedPlaceholder = attributedPlaceholder
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            passwordTF.text = ""
            passwordConfirmTF.text = ""
        }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let dispatchGroup = DispatchGroup()
        var shouldPerformSegue = true
        if identifier == "1to2" {
            dispatchGroup.enter()
            if(nameTF.text!.count == 0){
                nameErr.text = "This field is required"
                nameErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if(nameTF.text!.count < 3){
                nameErr.text = "Name must be at least 3 characters long"
                nameErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else {
                nameErr.isHidden = true
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            if(mailTF.text!.count == 0){
                mailErr.text = "This field is required"
                mailErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if !isValidEmail(mailTF.text!) {
                mailErr.text = "Invalid email address"
                mailErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if dbUser.emailExists(email: mailTF.text!) {
                mailErr.text = "Email address already exists"
                mailErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else {
                mailErr.isHidden = true
                dispatchGroup.leave()
            }
            dispatchGroup.enter()
            if(usernameTF.text!.count == 0){
                usernameErr.text = "This field is required"
                usernameErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if(usernameTF.text!.count < 5){
                usernameErr.text = "Username must be at least 5 characters long"
                usernameErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if(usernameTF.text!.count > 12){
                usernameErr.text = "Username cannot exceed 12 characters in length"
                usernameErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if dbUser.userExists(username: usernameTF.text!) {
                usernameErr.text = "Username already exists"
                usernameErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if(usernameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                usernameErr.text = "Invalid username"
                usernameErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if(usernameTF.text!.contains(where: { $0.isWhitespace })) {
                usernameErr.text = "No whitespace allowed"
                usernameErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else {
                usernameErr.isHidden = true
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            if(passwordTF.text!.count == 0){
                passErr.text = "This field is required"
                passErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if(passwordTF.text!.count < 6){
                passErr.text = "Password must be at least 6 characters long"
                passErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if(passwordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || passwordTF.text!.contains(where: { $0.isWhitespace })){
                passErr.text = "Invalid password"
                passErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else {
                passErr.isHidden = true
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            if(passwordConfirmTF.text!.count == 0){
                passCnfErr.text = "This field is required"
                passCnfErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else if(passwordTF.text != passwordConfirmTF.text){
                passCnfErr.text = "Passwords don't match"
                passCnfErr.isHidden = false
                shouldPerformSegue = false
                dispatchGroup.leave()
            } else {
                passCnfErr.isHidden = true
                dispatchGroup.leave()
            }
        }
        return shouldPerformSegue
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "1to2" {
            if let destinationVC = segue.destination as? CreateAccount2VC {
                destinationVC.nameTF = nameTF.text!
                destinationVC.mailTF = mailTF.text!
                destinationVC.usernameTF = usernameTF.text!
                destinationVC.passwordTF = passwordTF.text!
            }
        }
    }
}
extension CreateAccount1VC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField.restorationIdentifier == "nameTF") {
            let allowedCharacterSet = CharacterSet.letters
            let typedCharacterSet = CharacterSet(charactersIn: string)
            return allowedCharacterSet.isSuperset(of: typedCharacterSet)
            
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
            let defaults = UserDefaults.standard
            if textField == nameTF {
                defaults.set(nameTF.text, forKey: "name")
            } else if textField == mailTF {
                defaults.set(mailTF.text, forKey: "mail")
            } else if textField == usernameTF {
                defaults.set(usernameTF.text, forKey: "username")
            }
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      return true
    }


}


