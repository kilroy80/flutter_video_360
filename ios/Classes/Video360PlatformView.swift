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
        self._view = UIView(frame: frame)
        self._view.backgroundColor = .yellow
        
        super.init()
        
        let nativeView = Video360View(
            viewId: String(format: "kino_video_360_%lld", viewId),
            messenger: registrar.messenger()
        )
        nativeView.frame = self._view.bounds
        self._view.addSubview(nativeView)
    }
    
    func view() -> UIView {
        return self._view
    }
}
