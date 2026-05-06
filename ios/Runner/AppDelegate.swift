import UIKit
import Flutter
import GoogleMaps
import AppsFlyerLib
import FirebaseMessaging
import FirebaseCore
import SmartPush
import Smartech 
import smartech_base 

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GMSServices.provideAPIKey("AIzaSyCBFuMTFiBOwMOAbiCNJFInpiknSupbfEc")

    // ── AppsFlyer: MUST be initialized here, before Flutter starts, so that
    //    Universal Link / OneLink clicks are processed immediately when the app
    //    opens — not after a Dart-side delay.
    AppsFlyerLib.shared().appsFlyerDevKey = "tzivSReYr7ZyuqVbEP6z6d"
    AppsFlyerLib.shared().appleAppID    = "6739497338"
    AppsFlyerLib.shared().isDebug       = false   // set true only for local debug builds
    // Let the Dart side handle attribution/deep-link callbacks via the plugin.
    // Native start is still required so the SDK is ready for Universal Links.
    AppsFlyerLib.shared().start()

    GeneratedPluginRegistrant.register(with: self)

    // ── Firebase Messaging: required when FirebaseAppDelegateProxyEnabled = false
    Messaging.messaging().delegate = self
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    application.registerForRemoteNotifications()

    // ── Netcore CE: register for push notifications
    SmartPush.sharedInstance().registerForPushNotificationWithDefaultAuthorizationOptions()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ── Firebase: pass APNS token manually (FirebaseAppDelegateProxyEnabled = false)
  // ── Netcore CE: also forward APNS token to SmartPush
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    SmartPush.sharedInstance().didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    SmartPush.sharedInstance().didFailToRegisterForRemoteNotificationsWithError(error)
  }

  // ── Custom URL scheme handler (lafetch://) — forward to AppsFlyer
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    AppsFlyerLib.shared().handleOpen(url, options: options)
    return super.application(app, open: url, options: options)
  }

  // ── Universal Links (https://lafetch.onelink.me/...) — forward to AppsFlyer
  //    Return true immediately so iOS knows the link is handled and does NOT
  //    fall back to opening Safari.
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }

  // ── UNUserNotificationCenterDelegate: foreground notification display
  // ── Netcore CE: forward to SmartPush for in-app handling
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    SmartPush.sharedInstance().willPresentForegroundNotification(notification)
    completionHandler([.alert, .badge, .sound])
  }

  // ── UNUserNotificationCenterDelegate: notification tap response
  // ── Netcore CE: forward to SmartPush for deeplink handling
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    SmartPush.sharedInstance().didReceive(response)
    completionHandler()
  }
}

// // ── Netcore CE: deeplink delegate — forwards notification tap deeplinks to the Flutter layer
// extension AppDelegate: SMTDeeplinkDelegate {
//   func handleDeeplinkAction(withURLString urlString: String, andNotificationPayload payload: [AnyHashable: Any]) {
//     SmartechBasePlugin.handleDeeplinkAction(urlString, andCustomPayload: payload)
//   }
// }

// Required when FirebaseAppDelegateProxyEnabled = false
// Handles FCM token refresh at the native level
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("FCM token refreshed: \(fcmToken ?? "nil")")
    // The flutter_firebase_messaging plugin handles Dart-side token via its own channel.
    // This native callback ensures token refresh is not missed when proxy is disabled.
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}
