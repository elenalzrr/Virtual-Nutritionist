import UIKit
import CryptoKit
import SwiftyPickerPopover
import PMAlertController
class SettingsVC: UITableViewController {

    @IBOutlet var nameLabel: UILabel!
    var userId: Int = 0
    var dbUser = DBManagerUser()
    @IBOutlet var backButton: UIButton!
    
    @IBOutlet var mailLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    
    @IBOutlet var birthdayLabel: UILabel!
    @IBOutlet var birthdayPicker: UIButton!

    private var selectedRowGender: Int = 1
    @IBOutlet var genderLabel: UILabel!
    
    @IBOutlet var heightButton: UIButton!
    
    private var selectedRowHeight: Int = 0
    @IBOutlet var heightLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        userId = SingletonUser.shared.userId
        nameLabel.text = dbUser.getName(id: userId)
        mailLabel.text = dbUser.getEmail(id: userId)
        usernameLabel.text = dbUser.getUsername(id: userId)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: dbUser.getUserBirthday(userID: userId)!)
        birthdayLabel.text = dateString
        genderLabel.text = dbUser.getUserGender(userID: userId)
        let heightint = dbUser.getUserHeight(userID: userId)
        let heightString = "\(heightint ?? 0) cm"
        heightLabel.text = heightString
        selectedRowHeight = dbUser.getUserHeight(userID: userId)! - 140



    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 1) {
            guard let lobsterTwoFontBold = UIFont(name: "LobsterTwo-Bold", size: 24) else {
                fatalError("Couldn't load LobsterTwo-Bold font")
            }
            guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 18) else {
                fatalError("Couldn't load LobsterTwo-Bold font")
            }
            let alertController = UIAlertController(title: "Please enter the new name", message: nil, preferredStyle: .alert)
            
            let titleString = NSAttributedString(string: "Please enter the new name", attributes: [
                .foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                .font: lobsterTwoFontBold
            ])
            alertController.setValue(titleString, forKey: "attributedTitle")
            
            alertController.addTextField(configurationHandler: { textField in
                textField.placeholder = self.dbUser.getName(id: self.userId)
                textField.textColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                textField.font = lobsterTwoFont
            })
            
            alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak alertController] _ in
                guard let alertController = alertController, let textField = alertController.textFields?.first else {
                    return
                }
                
                let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let name = trimmedText, !name.isEmpty, name.rangeOfCharacter(from: CharacterSet.letters.inverted) == nil else {
                    let errorAlert = UIAlertController(title: "Error", message: "Please enter a valid name.", preferredStyle: .alert)
                    errorAlert.view.tintColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                    let attributes = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 24)!
                    ]
                    let attributesMessage = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 18)!
                    ]
                    let attributedTitle = NSAttributedString(string: "Error", attributes: attributes)
                    errorAlert.setValue(attributedTitle, forKey: "attributedTitle")
                    let attributedMessage = NSAttributedString(string: "Please enter a valid name.", attributes: attributesMessage)
                    errorAlert.setValue(attributedMessage, forKey: "attributedMessage")
                    errorAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }
                
                if (self.dbUser.getName(id: self.userId) == name) {
                    let errorAlert = UIAlertController(title: "Error", message: "You entered the same name.", preferredStyle: .alert)
                    errorAlert.view.tintColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                    let attributes = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 24)!
                    ]
                    let attributesMessage = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 18)!
                    ]
                    let attributedTitle = NSAttributedString(string: "Error", attributes: attributes)
                    errorAlert.setValue(attributedTitle, forKey: "attributedTitle")
                    let attributedMessage = NSAttributedString(string: "You entered the same name.", attributes: attributesMessage)
                    errorAlert.setValue(attributedMessage, forKey: "attributedMessage")
                    errorAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }
                self.nameLabel.text = name
                self.dbUser.updateName(id: self.userId, newName: name)
            })
            
            
            
            saveAction.setValue(UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0), forKey: "titleTextColor")
            alertController.addAction(saveAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            cancelAction.setValue(UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0), forKey: "titleTextColor")
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
        
        if(indexPath.row == 2) {
            guard let lobsterTwoFontBold = UIFont(name: "LobsterTwo-Bold", size: 24) else {
                fatalError("Couldn't load LobsterTwo-Bold font")
            }
            guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 18) else {
                fatalError("Couldn't load LobsterTwo-Bold font")
            }
            
            let alertController = UIAlertController(title: "Please enter the new username", message: nil, preferredStyle: .alert)
            
            let titleString = NSAttributedString(string: "Please enter the new username", attributes: [
                .foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                .font: lobsterTwoFontBold
            ])
            alertController.setValue(titleString, forKey: "attributedTitle")
            
            alertController.addTextField(configurationHandler: { textField in
                textField.placeholder = self.dbUser.getUsername(id: self.userId)
                textField.textColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                textField.font = lobsterTwoFont
            })
            
            alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak alertController] _ in
                guard let alertController = alertController, let textField = alertController.textFields?.first else {
                    return
                }
                
                let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let username = trimmedText, !username.isEmpty else {
                    let errorAlert = UIAlertController(title: "Error", message: "Please enter a valid username.", preferredStyle: .alert)
                    errorAlert.view.tintColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                    let attributes = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 24)!
                    ]
                    let attributesMessage = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 18)!
                    ]
                    let attributedTitle = NSAttributedString(string: "Error", attributes: attributes)
                    errorAlert.setValue(attributedTitle, forKey: "attributedTitle")
                    let attributedMessage = NSAttributedString(string: "Please enter a valid username.", attributes: attributesMessage)
                    errorAlert.setValue(attributedMessage, forKey: "attributedMessage")
                    errorAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }
                if (self.dbUser.getUsername(id: self.userId) == username) {
                    let errorAlert = UIAlertController(title: "Error", message: "You entered the same username.", preferredStyle: .alert)
                    errorAlert.view.tintColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                    let attributes = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 24)!
                    ]
                    let attributesMessage = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 18)!
                    ]
                    let attributedTitle = NSAttributedString(string: "Error", attributes: attributes)
                    errorAlert.setValue(attributedTitle, forKey: "attributedTitle")
                    let attributedMessage = NSAttributedString(string: "You entered the same username.", attributes: attributesMessage)
                    errorAlert.setValue(attributedMessage, forKey: "attributedMessage")
                    errorAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }
                if self.dbUser.userExists(username: username) {
                    let errorAlert = UIAlertController(title: "Error", message: "This username already exists. Please choose another one.", preferredStyle: .alert)
                    errorAlert.view.tintColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                    let attributes = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 24)!
                    ]
                    let attributesMessage = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 18)!
                    ]
                    let attributedTitle = NSAttributedString(string: "Error", attributes: attributes)
                    errorAlert.setValue(attributedTitle, forKey: "attributedTitle")
                    let attributedMessage = NSAttributedString(string: "This username already exists. Please choose another one.", attributes: attributesMessage)
                    errorAlert.setValue(attributedMessage, forKey: "attributedMessage")
                    errorAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }
                self.usernameLabel.text = username
                self.dbUser.updateUsername(id: self.userId, newUsername: username)
                
                
            })
            saveAction.setValue(UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0), forKey: "titleTextColor")
            alertController.addAction(saveAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            cancelAction.setValue(UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0), forKey: "titleTextColor")
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
        if (indexPath.row == 3) {
            guard let lobsterTwoFontBold = UIFont(name: "LobsterTwo-Bold", size: 24) else {
                fatalError("Couldn't load LobsterTwo-Bold font")
            }
            guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 18) else {
                fatalError("Couldn't load LobsterTwo-Bold font")
            }
            
            let alertController = UIAlertController(title: "Please enter the new email", message: nil, preferredStyle: .alert)
            
            let titleString = NSAttributedString(string: "Please enter the new email", attributes: [
                .foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                .font: lobsterTwoFontBold
            ])
            alertController.setValue(titleString, forKey: "attributedTitle")
            
            alertController.addTextField(configurationHandler: { textField in
                textField.placeholder = self.dbUser.getEmail(id: self.userId)
                textField.textColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                textField.font = lobsterTwoFont
            })
            
            alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak alertController] _ in
                guard let alertController = alertController, let textField = alertController.textFields?.first else {
                    return
                }
                
                let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let isValidEmail = NSPredicate(format:"SELF MATCHES %@", emailRegex).evaluate(with: trimmedText)
                
                guard let email = trimmedText, !email.isEmpty, isValidEmail else {
                    let errorAlert = UIAlertController(title: "Error", message: "Please enter a valid email address.", preferredStyle: .alert)
                    errorAlert.view.tintColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                    let attributes = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 24)!
                    ]
                    let attributesMessage = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 18)!
                    ]
                    let attributedTitle = NSAttributedString(string: "Error", attributes: attributes)
                    errorAlert.setValue(attributedTitle, forKey: "attributedTitle")
                    let attributedMessage = NSAttributedString(string: "Please enter a valid email address.", attributes: attributesMessage)
                    errorAlert.setValue(attributedMessage, forKey: "attributedMessage")
                    errorAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }
                if (self.dbUser.getEmail(id: self.userId) == email) {
                    let errorAlert = UIAlertController(title: "Error", message: "You entered the same email.", preferredStyle: .alert)
                    errorAlert.view.tintColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                    let attributes = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 24)!
                    ]
                    let attributesMessage = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 18)!
                    ]
                    let attributedTitle = NSAttributedString(string: "Error", attributes: attributes)
                    errorAlert.setValue(attributedTitle, forKey: "attributedTitle")
                    let attributedMessage = NSAttributedString(string: "You entered the same email.", attributes: attributesMessage)
                    errorAlert.setValue(attributedMessage, forKey: "attributedMessage")
                    errorAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }
                
                if self.dbUser.emailExists(email: email) {
                    let errorAlert = UIAlertController(title: "Error", message: "This email already exists. Please choose another one.", preferredStyle: .alert)
                    errorAlert.view.tintColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                    let attributes = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 24)!
                    ]
                    let attributesMessage = [
                        NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),
                        NSAttributedString.Key.font: UIFont(name: "LobsterTwo", size: 18)!
                    ]
                    let attributedTitle = NSAttributedString(string: "Error", attributes: attributes)
                    errorAlert.setValue(attributedTitle, forKey: "attributedTitle")
                    let attributedMessage = NSAttributedString(string: "This email already exists. Please choose another one.", attributes: attributesMessage)
                    errorAlert.setValue(attributedMessage, forKey: "attributedMessage")
                    errorAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }
                
                self.mailLabel.text = email
                self.dbUser.updateEmail(id: self.userId, newEmail: email)
                })
                saveAction.setValue(UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0), forKey: "titleTextColor")
                alertController.addAction(saveAction)
                                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                cancelAction.setValue(UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0), forKey: "titleTextColor")
                alertController.addAction(cancelAction)
                                
                self.present(alertController, animated: true, completion: nil)
                }
        
        if(indexPath.row == 7){
            print("s a selectat")
            guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
                fatalError("Couldn't load LobsterTwo-Bold font")
            }

            let alertVC = PMAlertController(title: "Change Password", description: nil, image: nil, style: .alert)

            alertVC.addTextField { (textField) in

                let attributedString = NSAttributedString(string: "Old Password", attributes: [NSAttributedString.Key.foregroundColor:UIColor(red: 0.91, green: 0.71, blue: 0.76, alpha: 1.0)])
                textField!.attributedPlaceholder = attributedString

                textField?.font = lobsterTwoFont
                textField?.textColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                textField?.isSecureTextEntry = true
                    }
            
            
            alertVC.addTextField { (textField) in
                let attributedString = NSAttributedString(string: "New Password", attributes: [NSAttributedString.Key.foregroundColor:UIColor(red: 0.91, green: 0.71, blue: 0.76, alpha: 1.0)])
                textField!.attributedPlaceholder = attributedString
                textField?.font = lobsterTwoFont
                textField?.textColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                textField?.isSecureTextEntry = true
                    }
            
            
            alertVC.addTextField { (textField) in
                let attributedString = NSAttributedString(string: "Confirm New Password", attributes: [NSAttributedString.Key.foregroundColor:  UIColor(red: 0.91, green: 0.71, blue: 0.76, alpha: 1.0)])
                textField!.attributedPlaceholder = attributedString
                textField?.font = lobsterTwoFont
                textField?.textColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                textField?.isSecureTextEntry = true
                    }
            
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in

                    }))

            alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in

                let oldPasswordHash = SHA256.hash(data: Data(alertVC.textFields[0].text!.utf8)).compactMap { String(format: "%02x", $0) }.joined()
                if( alertVC.textFields[0].text != "" && alertVC.textFields[1].text != "" && alertVC.textFields[2].text != ""){
                    if(oldPasswordHash == self.dbUser.getPasswordForUser(withId: self.userId)) {

                        if(alertVC.textFields[1].text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false || alertVC.textFields[1].text!.contains(" ") == false){
                            if(alertVC.textFields[1].text!.count >= 6) {
                                if(alertVC.textFields[1].text == alertVC.textFields[2].text) {
                                    self.dbUser.updatePassword(id: self.userId, newPassword: alertVC.textFields[1].text!)
                                } else {
                                    let alertVC2 = PMAlertController(title: "Wrong credentials", description: "Passwords don't match!", image: nil, style: .alert)
                                    alertVC2.addAction(PMAlertAction(title: "Ok", style: .cancel, action: { () -> Void in
                                    }))
                                    self.present(alertVC2, animated: true, completion: nil)
                                }
                            } else {
                                let alertVC2 = PMAlertController(title: "Wrong credentials", description: "Password must be at least 6 characters long!", image: nil, style: .alert)
                                alertVC2.addAction(PMAlertAction(title: "Ok", style: .cancel, action: { () -> Void in
                                }))
                                self.present(alertVC2, animated: true, completion: nil)
                            }
                        } else {
                            let alertVC2 = PMAlertController(title: "Wrong credentials", description: "Invalid new password", image: nil, style: .alert)
                            alertVC2.addAction(PMAlertAction(title: "Ok", style: .cancel, action: { () -> Void in
                                
                            }))
                            self.present(alertVC2, animated: true, completion: nil)
                        }
                                                             
                    } else {
                        let alertVC2 = PMAlertController(title: "Wrong credentials", description: "Incorrect old password, try again!", image: nil, style: .alert)
                        alertVC2.addAction(PMAlertAction(title: "Ok", style: .cancel, action: { () -> Void in
                            
                        }))
                        self.present(alertVC2, animated: true, completion: nil)
                        
                    }
                } else {
                    let alertVC2 = PMAlertController(title: "Wrong credentials", description: nil, image: nil, style: .alert)
                    alertVC2.addAction(PMAlertAction(title: "Ok", style: .cancel, action: { () -> Void in
                        
                    }))
                    self.present(alertVC2, animated: true, completion: nil)
                }
                    }))



            self.present(alertVC, animated: true, completion: nil)
           
            
        }

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settings" {
            if let tabBarController = segue.destination as? UITabBarController {
                tabBarController.selectedIndex = 2
                tabBarController.modalPresentationStyle = .fullScreen
            }
        }
    }

    @IBAction func genderButton(_ sender: Any) {
        guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
            fatalError("Couldn't load LobsterTwo-Bold font")
        }
        if(dbUser.getUserGender(userID: userId) == "female"){
            selectedRowGender = 1
        } else {
            selectedRowGender = 0
        }
                let displayStringFor:((String?)->String?)? = { string in
                    if let s = string {
                        switch(s){
                        case "value 1":
                            return "Male"
                        case "value 2":
                            return "Female"
                        default:
                            return s
                        }
                    }
                    return nil
                }
                
                let p = StringPickerPopover(title: "Gender", choices: ["value 1","value 2"])
                    .setDisplayStringFor(displayStringFor)
                    .setValueChange(action: { _, _, selectedString in
                        
                    })
                    .setDoneButton(
                        font: lobsterTwoFont,
                        action: { popover, selectedRow, selectedString in
                            print("done row \(selectedRow) \(selectedString)")
                            self.selectedRowGender = selectedRow
                            if(selectedRow == 0) {
                                self.genderLabel.text = "Male"
                                self.dbUser.updateGender(id: self.userId, newGender: "male")
                            }
                            if(selectedRow == 1) {
                                self.genderLabel.text = "Female"
                                self.dbUser.updateGender(id: self.userId, newGender: "female")
                            }
                            
                    })
                    .setCancelButton(font:lobsterTwoFont,
                                     action: {_, _, _ in
                         })
                .setSelectedRow(selectedRowGender)
        p.appear(originView: sender as! UIView, baseViewController: self)

    }
    
    @IBAction func birthdayPicker(_ sender: Any) {
        let dateString = "01/01/2006"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.date(from: dateString)

        let dateString2 = "01/01/1930"
        let datemin = dateFormatter.date(from: dateString2)
        guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
            fatalError("Couldn't load LobsterTwo-Bold font")
        }
        
        DatePickerPopover(title: "Birthday")
                    .setDateMode(.date)
                    .setSelectedDate(dbUser.getUserBirthday(userID: userId)!)
                    .setValueChange(action: { _, selectedDate in

                    })
                    .setMaximumDate(date!)
                    .setMinimumDate(datemin!)
                    .setDoneButton(title:"Save", font:lobsterTwoFont, color:UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),action: { popover, selectedDate in
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        let dateString = dateFormatter.string(from: selectedDate)
                        self.birthdayLabel.text = dateString
                        self.dbUser.updateBirthday(id: self.userId, newBirthday: selectedDate)})
                    .setCancelButton(title:"Cancel", font:lobsterTwoFont, color:UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),action: { _, _ in print("cancel")})
                    .appear(originView: sender as! UIView, baseViewController: self)
    }
    
    
    @IBAction func heightAction(_ sender: Any) {
        guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
            fatalError("Couldn't load LobsterTwo-Bold font")
        }


        let choices = (140...230).map { String($0) }
        let displayStringFor:((String?)->String?)? = { string in
            if let s = string, let intValue = Int(s) {
                return "\(intValue)"
            }
            return nil
        }
                
        let p = StringPickerPopover(title: "Height", choices: choices)
            .setDisplayStringFor(displayStringFor)
            .setValueChange(action: { _, selectedRow, selectedString in
                
            })
            .setDoneButton(
                    font: lobsterTwoFont,
                    action: { popover, selectedRow, selectedString in
                        self.selectedRowHeight = selectedRow
                        self.heightLabel.text = selectedString + " cm"
                        self.dbUser.updateHeight(id: self.userId, newHeight: selectedRow + 140)
                        
            })
                    .setCancelButton(font:lobsterTwoFont,
                                     action: {_, _, _ in
                })
                .setSelectedRow(selectedRowHeight)
        p.appear(originView: sender as! UIView, baseViewController: self)
    }
    
}

