import UIKit
import Toast
import SwiftyPickerPopover
class ReminderAddVC: UITableViewController, UITextFieldDelegate{
    
    
    @IBOutlet var nameTF: UITextField!
    
    
    var userId: Int = 0
    
    var dbReminders = DBManagerReminder()
    var dbUser = DBManagerUser()
    
    @IBOutlet var timeButton: UIButton!
    
    @IBOutlet var timeLabel: UILabel!
    var rids:[Int] = []
    var data: Date?
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        userId = SingletonUser.shared.userId
        nameTF.delegate = self
        let placeholderText = "Reminder name"
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)]
        nameTF.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        nameTF.text = "Reminder"
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date())
        let hour = components.hour
        let minute = components.minute
        timeLabel.text = String(hour!) + ":" + String(minute!)
        data = Date()
        
        
    }
    

    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
            fatalError("Couldn't load LobsterTwo-Bold font")
        }
        if identifier == "saveReminder" {

            if(nameTF.text != "") {

                if(dbReminders.checkReminderExists(forUserId: userId, date: data!) == true){

                    // create a new style
                    var style = ToastStyle()
                    let title = "Reminder already exists"
                    // this is just one of many style options
                    style.messageColor = .white
                    style.backgroundColor = UIColor(red: 0.8588, green: 0.5647, blue: 0.6431, alpha: 1.0)
                    style.titleFont = lobsterTwoFont
                    style.messageFont = lobsterTwoFont
                    // present the toast with the new style
                    self.view.makeToast(title, duration: 2.0, position: .top, style: style)



                    // toggle "tap to dismiss" functionality
                    ToastManager.shared.isTapToDismissEnabled = true

                    // toggle queueing behavior
                    ToastManager.shared.isQueueEnabled = true
                    return false

                } else {
                    dbReminders.insertReminder(user_id: userId, name: nameTF.text!, date: data!, isActive: false)
                }
            } else {
                let backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
                let textColor = UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0)
                let font = UIFont(name: "LobsterTwo", size: 18)
                let fontbold = UIFont(name: "LobsterTwo-Bold", size: 24)
                let alertController = UIAlertController(title: "Empty name", message: "Please enter a name.", preferredStyle: .alert)
                alertController.view.tintColor = textColor
                alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = backgroundColor

                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                okAction.setValue(textColor, forKey: "titleTextColor")

                alertController.addAction(okAction)
                alertController.setValue(NSAttributedString(string: "Empty name", attributes: [
                    NSAttributedString.Key.foregroundColor: textColor,
                    NSAttributedString.Key.font: fontbold!
                ]), forKey: "attributedTitle")
                alertController.setValue(NSAttributedString(string: "Please enter a name.", attributes: [
                    NSAttributedString.Key.foregroundColor: textColor,
                    NSAttributedString.Key.font: font!
                ]), forKey: "attributedMessage")

                self.present(alertController, animated: true, completion: nil)
                return false
            }
        }
        return true
    }

  
    @IBAction func timeAction(_ sender: Any) {
        guard let lobsterTwoFont = UIFont(name: "LobsterTwo", size: 22) else {
            fatalError("Couldn't load LobsterTwo-Bold font")
        }
        
        DatePickerPopover(title: "Time Picker")
                    .setDateMode(.time)
                    .setPermittedArrowDirections(.down)
                    .setValueChange(action: { _, selectedDate in
                        print("current date \(selectedDate)")
                    })
                    .setDoneButton(title:"Save", font:lobsterTwoFont, color:UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),action: { popover, selectedDate in
                        print("selectedDate \(selectedDate)")
                        self.data = selectedDate
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.hour, .minute], from: selectedDate)
                        let hour = components.hour
                        let minute = components.minute
                        self.timeLabel.text = String(hour!) + ":" + String(minute!)
                        
                        
                    } )
                    .setCancelButton(title:"Cancel", font:lobsterTwoFont, color:UIColor(red: 0.858, green: 0.565, blue: 0.643, alpha: 1.0),action: { _, _ in print("cancel")})
                    .appear(originView: sender as! UIView, baseViewController: self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = "" // șterge textul din textfield
    }
    


}
