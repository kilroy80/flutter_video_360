import Flutter
import UIKit

public class Video360Plugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // let channel = FlutterMethodChannel(name: "video_360", binaryMessenger: registrar.messenger())
    // let instance = Video360Plugin()
    // registrar.addMethodCallDelegate(instance, channel: channel)

    let factory = Video360ViewFactoy.init(registrar: registrar);
    registrar.register(factory, withId: "kino_video_360");
  }

  // public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
  //   switch call.method {
  //   case "getPlatformVersion":
  //     result("iOS " + UIDevice.current.systemVersion)
  //   default:
  //     result(FlutterMethodNotImplemented)
  //   }
  // }
}
