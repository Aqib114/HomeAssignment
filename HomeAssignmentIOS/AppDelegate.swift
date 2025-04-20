import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Request notification permissions when the app launches
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Notification permission granted.")
                } else {
                    print("Notification permission denied.")
                }
            }
            
            // Set UNUserNotificationCenter delegate
            UNUserNotificationCenter.current().delegate = NotificationManager.shared

            return true
        }
}

// Extension for handling notifications in foreground
extension AppDelegate: UNUserNotificationCenterDelegate {
    // This method will be called when a notification is received while the app is in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show alert and sound when a notification is received in the foreground
        completionHandler([.alert, .sound])
    }

    // This method will be called when the user taps on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap action
        completionHandler()
    }
}
