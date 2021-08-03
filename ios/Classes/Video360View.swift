import Flutter
import UIKit
import AVKit
import Swifty360Player

public class Video360View: UIView, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        print("register")
    }
    
    var player: AVPlayer!
    var channel: FlutterMethodChannel!
    var swifty360View: Swifty360View!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        print(frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func initFlutter(
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        flutterRegistrar registrar: FlutterPluginRegistrar
    ) {
        
        let viewName = String(format: "kino_video_360_%lld", viewId)
        print(viewName)
        let channel = FlutterMethodChannel(name: viewName,
                                           binaryMessenger: registrar.messenger())
        
        self.channel = channel
        
        registrar.addMethodCallDelegate(self, channel: channel)
        registrar.addApplicationDelegate(self)
    }
    
    
    private func initView(width: Double, height: Double) {
        guard let videoURL = URL(string: "http://www.solusvision.co.kr/arportal/gosam_lake/gosam_lake1/HLS/gosam_lake1.m3u8") else { return }
        player = AVPlayer(url: videoURL)

        let motionManager = Swifty360MotionManager.shared

        swifty360View = Swifty360View(withFrame: CGRect(x: 0.0, y: 0.0, width: width, height: height),
                                      player: player,
                                      motionManager: motionManager)
        swifty360View.setup(player: player, motionManager: motionManager)
        self.addSubview(swifty360View)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reorientVerticalCameraAngle))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func play() {
        player.play()
        print("play")

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { (time) in
            if let currentItem = self.player.currentItem {
                if currentItem.status == AVPlayerItem.Status.readyToPlay {
                        if currentItem.isPlaybackLikelyToKeepUp {
                            if (!self.player.isPlaying) {
                                print("Playing")
                                self.player.play()
                            }
                        } else if currentItem.isPlaybackBufferEmpty {
                            print("Buffer empty - show loader")
                        }  else if currentItem.isPlaybackBufferFull {
                            print("Buffer full - hide loader")
                        } else {
                            print("Buffering")
                        }
                } else if currentItem.status == AVPlayerItem.Status.failed {
                        print("Failed")
                } else if currentItem.status == AVPlayerItem.Status.unknown {
                        print("Unknown")
                    }
                } else {
                    print("avPlayer.currentItem is nil")
                }
        }
    }
    
    @objc func reorientVerticalCameraAngle() {
        swifty360View.reorientVerticalCameraAngleToHorizon(animated: true)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            guard let argMaps = call.arguments as? Dictionary<String, Any>,
                  let width = argMaps["width"] as? Double,
                  let height = argMaps["height"] as? Double else {
                    result(FlutterError(code: call.method, message: "Missing argument", details: nil))
                    return
            };
            self.initView(width: width, height: height)
        case "play":
            self.play()
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
