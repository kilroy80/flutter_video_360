import Flutter
import UIKit

public class SwiftVideo360Plugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
//    let channel = FlutterMethodChannel(name: "kino_video_360", binaryMessenger: registrar.messenger())
//    let instance = SwiftVideo360Plugin()
//    registrar.addMethodCallDelegate(instance, channel: channel)
    
    let factory = Video360ViewFactoy.init(registrar: registrar);
    registrar.register(factory, withId: "kino_video_360");
    print("init");
  }

//  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//    result("iOS " + UIDevice.current.systemVersion)
    
//    if (call.method.isEqual("openPlayer")) {
//        guard let appdelegate = UIApplication.shared.delegate as? FlutterAppDelegate else { return }
//
//      appdelegate.window.rootViewController = VRViewController()
//    }
//  }
}
