import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let channelName = "golf_kakis/device_id"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getDeviceId":
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device"
        result(deviceId)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
