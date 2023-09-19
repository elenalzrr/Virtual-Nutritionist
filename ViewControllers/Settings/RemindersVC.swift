import UIKit
class RemindersVC: UITableViewController {

    
    var userId: Int = 0
    
    var dbReminders = DBManagerReminder()
    var dbUser = DBManagerUser()
    var reminders: [(String, String, Bool)] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userId = SingletonUser.shared.userId
        

        if let fetchedReminders = dbReminders.getReminders(forUserId: userId) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"

            for fetchedReminder in fetchedReminders {
                let date = dateFormatter.string(from: fetchedReminder.1)
                let reminder = (fetchedReminder.0, date, fetchedReminder.2)
                reminders.append(reminder)
            }
        } else {
            // Handle error or no reminders found
        }

        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if let error = error {
                print("Error requesting authorization for notifications: \(error.localizedDescription)")
                return
            }

            if granted {
                print("Notification authorization granted.")
            } else {
                print("Notification authorization denied.")
            }
        }

        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reminders" {
            if let tabBarController = segue.destination as? UITabBarController {
                tabBarController.selectedIndex = 2
                tabBarController.modalPresentationStyle = .fullScreen
            }
        }
    }
    
    override func tableView(_ tableView: UITableView,
            numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reminders")
        cell.textLabel?.text = reminders.map { $0.0 }[indexPath.row]
        cell.textLabel?.font = UIFont(name: "LobsterTwo", size: 28)
        cell.textLabel?.textColor = UIColor(red: 213/255, green: 125/255, blue: 149/255, alpha: 1.0)
        cell.detailTextLabel?.text = reminders.map { $0.1 }[indexPath.row]
        cell.detailTextLabel?.font = UIFont(name: "LobsterTwo", size: 20)
        cell.detailTextLabel?.textColor = UIColor(red: 0.886, green: 0.639, blue: 0.702, alpha: 1.0)
        cell.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 0.792, green: 0.941, blue: 0.973, alpha: 1.0)
        cell.selectedBackgroundView = selectedBackgroundView

        let switchView = UISwitch()
            switchView.isOn = false
            switchView.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
            cell.contentView.addSubview(switchView)
            switchView.tintColor = UIColor(red: 0.886, green: 0.639, blue: 0.702, alpha: 1.0)
            switchView.thumbTintColor = UIColor(red: 213/255, green: 125/255, blue: 149/255, alpha: 1.0)
            switchView.onTintColor = UIColor(red: 0.886, green: 0.639, blue: 0.702, alpha: 1.0)
            switchView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                switchView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                switchView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20)
            ])


        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    func scheduleNotification(at date: Date, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    @objc func switchChanged(sender: UISwitch) {
        guard let cell = sender.superview?.superview as? UITableViewCell else {
            return
        }

        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let inputString = self.reminders[indexPath.row].1

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm"

        let date = inputFormatter.date(from: inputString)

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"

        let outputString = outputFormatter.string(from: date!)

        let outputDate = outputFormatter.date(from: outputString)
        if sender.isOn {

            dbReminders.updateReminderIsActive(forUserId: userId, date: outputDate!, isActive: true)
            let content = UNMutableNotificationContent()
            content.title = "Reminder"
            content.body = "It's time for \(reminders[indexPath.row].0)"
            content.sound = UNNotificationSound.default

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let date = dateFormatter.date(from: reminders[indexPath.row].1)
            let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: date!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            let request = UNNotificationRequest(identifier: "reminder_\(indexPath.row)", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        } else {
            dbReminders.updateReminderIsActive(forUserId: userId, date: outputDate!, isActive: false)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["reminder_\(indexPath.row)"])
        }
        
    }


    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in

            let inputString = self!.reminders.map{ $0.1}[indexPath.row]

            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "HH:mm"

            let date = inputFormatter.date(from: inputString)

            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "HH:mm"

            let outputString = outputFormatter.string(from: date!)

            let outputDate = outputFormatter.date(from: outputString)
            self!.dbReminders.deleteReminders(fromDate: outputDate!, forUserId: self!.userId)
            self?.reminders.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)


            completionHandler(true)
        }
        deleteAction.backgroundColor = UIColor(red: 0.886, green: 0.639, blue: 0.702, alpha: 1.0)
        deleteAction.image = UIImage(systemName: "trash.fill")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
