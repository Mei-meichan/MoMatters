import UIKit
import UserNotifications


class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // MARK: - Properties
    var window: UIWindow?

    // MARK: - UIApplicationDelegate Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request Permission for Local Notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    // Register for local notifications (this is for handling badge count, etc.)
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Local notification permission denied")
            }
        }
        
        // Set the delegate for handling notifications
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // MARK: - Local Notification Methods

    func scheduleLocalNotification(with message: String) {
        let content = UNMutableNotificationContent()
        content.title = "New Notification"
        content.body = message
        content.sound = .default

        // Set the badge number to simulate unread notifications
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)

        // Create a notification request (this will trigger immediately)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

        // Add the notification to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling local notification: \(error.localizedDescription)")
            }
        }
    }

    // Called when the app receives a notification while it is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show alert, sound, or badge based on notification content
        completionHandler([.alert, .sound])
    }

    // Called when the user taps on a notification (while app is in the background or terminated)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the notification response (e.g., navigate to a specific screen)
        print("Notification tapped: \(response.notification.request.content.body)")
        
        // For example, reset the badge number after a tap
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }

    // MARK: - Handling Background Fetch (Simulate Notification Update)
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Simulate checking for new unread notifications
        print("Performing background fetch for new notifications...")

        // Example: Fetch new notifications (you would do this from your data source or API)
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let newUnreadCount = 5 // Simulate new unread notifications
            self.scheduleLocalNotification(with: "You have \(newUnreadCount) new notifications.")
            completionHandler(.newData)
        }
    }
}
