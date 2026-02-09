import UIKit
import Flutter
import GoogleMaps
import AppsFlyerLib

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GMSServices.provideAPIKey("AIzaSyCBFuMTFiBOwMOAbiCNJFInpiknSupbfEc")

    // REMOVE Facebook SDK initialization (you no longer use Facebook)
    // ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
