import UIKit
import Flutter
import GoogleMaps
import AppsFlyerLib
import FirebaseMessaging
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GMSServices.provideAPIKey("AIzaSyCBFuMTFiBOwMOAbiCNJFInpiknSupbfEc")

    GeneratedPluginRegistrant.register(with: self)

    // Register for remote notifications (required when FirebaseAppDelegateProxyEnabled = false)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // CRITICAL: Manually pass APNS token to Firebase since FirebaseAppDelegateProxyEnabled = false
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {

    // REMOVE Facebook URL handler
    // if ApplicationDelegate.shared.application(app, open: url, options: options) {
    //   return true
    // }

    return super.application(app, open: url, options: options)
  }

  // Handle Universal Links - forward to AppsFlyer
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    // Forward Universal Links to AppsFlyer
    AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}
