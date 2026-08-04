import Flutter
import UIKit

class Video360PlatformView: NSObject, FlutterPlatformView {
    
    private var _view: UIView
    private let nativeView: Video360View

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        flutterRegistrar registrar: FlutterPluginRegistrar
    ) {
        self._view = UIView(frame: frame)
        self._view.backgroundColor = .yellow
        self.nativeView = Video360View(
            viewId: String(format: "kino_video_360_%lld", viewId),
            messenger: registrar.messenger()
        )

        super.init()

        nativeView.frame = self._view.bounds
        nativeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self._view.addSubview(nativeView)
    }
    
    func view() -> UIView {
        return self._view
    }

    deinit {
        nativeView.dispose()
    }
}
