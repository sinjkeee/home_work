import UIKit
import KeychainSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        hasRunBefore()
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
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


    // method to check the first launch of the application and remove the key from the keychain
    func hasRunBefore() {
        if !UserDefaults.standard.bool(forKey: "hasRunBefore") {
            let keychain = KeychainSwift()
            keychain.clear()
            UserDefaults.standard.set(true, forKey: "hasRunBefore")
        }
    }
}

