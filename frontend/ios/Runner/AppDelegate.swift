import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller = window?.rootViewController as! FlutterViewController
    let appInfoChannel = FlutterMethodChannel(
      name: "com.example.app/appinfo",
      binaryMessenger: controller.binaryMessenger
    )
    
    appInfoChannel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "getVersion":
        result(self?.getAppVersion())
      case "getBuildNumber":
        result(self?.getAppBuildNumber())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func getAppVersion() -> String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
  }
  
  private func getAppBuildNumber() -> String {
    return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
  }
}
