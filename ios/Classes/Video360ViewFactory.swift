import Flutter
import UIKit
 
public class Video360ViewFactoy: NSObject, FlutterPlatformViewFactory {
    
    private var registrar: FlutterPluginRegistrar
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }
    
    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return Video360PlatformView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            flutterRegistrar: registrar)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
