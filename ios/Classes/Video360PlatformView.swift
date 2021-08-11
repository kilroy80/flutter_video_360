import Flutter
import UIKit

class Video360PlatformView: NSObject, FlutterPlatformView {
    
    private var _view: UIView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        flutterRegistrar registrar: FlutterPluginRegistrar
    ) {
        _view = UIView(frame: frame)
        _view.backgroundColor = UIColor.black
        
        super.init()
        
        let nativeView = Video360View(
            viewId: String(format: "kino_video_360_%lld", viewId),
            messenger: registrar.messenger()
        )
        nativeView.frame = _view.bounds
        _view.addSubview(nativeView)
    }
    
    func view() -> UIView {
        return _view
    }
}
