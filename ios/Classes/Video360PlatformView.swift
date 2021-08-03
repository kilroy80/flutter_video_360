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
        // iOS views can be created here
//        createNativeView(view: _view)
        
        let nativeView = Video360View()
        nativeView.initFlutter(
            viewIdentifier: viewId,
            arguments: args,
            flutterRegistrar: registrar
        )
        nativeView.frame = _view.bounds
        _view.addSubview(nativeView)
    }

    func view() -> UIView {
        return _view
    }

//    func createNativeView(view _view: UIView){
//        _view.backgroundColor = UIColor.blue
//        let nativeLabel = UILabel()
//        nativeLabel.text = "Native text from iOS"
//        nativeLabel.textColor = UIColor.white
//        nativeLabel.textAlignment = .center
//        nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
//        _view.addSubview(nativeLabel)
//    }
}
