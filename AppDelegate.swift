
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "name")
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "mail")
        defaults.removeObject(forKey: "weight")
        defaults.removeObject(forKey: "height")
        defaults.removeObject(forKey: "goalweight")
        defaults.removeObject(forKey: "selectedDate")
        defaults.removeObject(forKey: "selectedSegmentIndex")
        defaults.removeObject(forKey: "lifestyle")
        defaults.removeObject(forKey: "goal")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

