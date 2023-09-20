import Flutter
import UIKit

public class SwiftVideo360Plugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = Video360ViewFactory.init(registrar: registrar);
    registrar.register(factory, withId: "kino_video_360");
  }
}
