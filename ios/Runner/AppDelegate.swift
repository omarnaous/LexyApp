import UIKit
import Flutter
import GoogleMaps
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps API Key
    GMSServices.provideAPIKey("AIzaSyDLQuFQJ3NywrYLHlKTmSNIlTrHmIBnOgo")

    // Firebase initialization
    FirebaseApp.configure()

    // Register for push notifications
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    // Flutter plugin registration
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Called when APNs has assigned a device token
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Pass the APNs token to Firebase
    Messaging.messaging().apnsToken = deviceToken
    print("APNs Device Token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // Called when APNs registration fails
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  // Handle notifications when the app is in the foreground
    override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    print("Foreground notification received: \(userInfo)")

    // Show alert, play sound, and update badge
    completionHandler([.banner, .sound, .badge]) // Updated for iOS 14+
  }

  // Handle notifications when the app is in the background or user taps on a notification
    override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    print("Background or tapped notification received: \(userInfo)")

    completionHandler()
  }
}
