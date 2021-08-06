import Flutter
import UIKit
import AVKit
import Swifty360Player

public class Video360View: UIView, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {}

    private var timer: Timer?

    var player: AVPlayer!
    var channel: FlutterMethodChannel!
    var swifty360View: Swifty360View!



    public func initFlutter(
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        flutterRegistrar registrar: FlutterPluginRegistrar
    ) {

        let viewName = String(format: "kino_video_360_%lld", viewId)
        print(viewName)
        self.channel = FlutterMethodChannel(name: viewName,
                                            binaryMessenger: registrar.messenger())


        registrar.addMethodCallDelegate(self, channel: self.channel)
        registrar.addApplicationDelegate(self)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            guard let argMaps = call.arguments as? Dictionary<String, Any>,
                  let url = argMaps["url"] as? String,
                  let width = argMaps["width"] as? Double,
                  let height = argMaps["height"] as? Double else {
                result(FlutterError(code: call.method, message: "Missing argument", details: nil))
                return
            }
            self.initView(url: url, width: width, height: height)
            self.checkPlayerState()
            self.updateTime()

        case "play":
            self.play()

        case "stop":
            self.stop()

        case "reset":
            self.reset()

        case "searchTime":
            guard let argMaps = call.arguments as? Dictionary<String, Any>,
                  let time = argMaps["searchTime"] as? Double else {
                result(FlutterError(code: call.method, message: "Missing argument", details: nil))
                return
            }
            self.searchTime(time: time)

        case "moveTime":
            guard let argMaps = call.arguments as? Dictionary<String, Any>,
                  let time = argMaps["moveTime"] as? Double else {
                result(FlutterError(code: call.method, message: "Missing argument", details: nil))
                return
            }
            self.moveTime(time: time)

        case "gesture":
            guard let argMaps = call.arguments as? Dictionary<String, Any>,
                  let x = argMaps["x"] as? Double, x > 0,
                  let y = argMaps["y"] as? Double, y > 0 else {
                result(FlutterError(code: call.method, message: "Missing argument", details: nil))
                return
            }
            let point = CGPoint(x: x, y: y)
            print("----------------- \(point) -----------------")
            self.swifty360View.cameraController.handlePan(point: point)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}



// MARK: - Interface

extension Video360View {

    private func initView(url: String, width: Double, height: Double) {
        guard let videoURL = URL(string: url) else { return }
        self.player = AVPlayer(url: videoURL)

        let motionManager = Swifty360MotionManager.shared

        self.swifty360View = Swifty360View(withFrame: CGRect(x: 0.0, y: 0.0, width: width, height: height),
                                           player: self.player,
                                           motionManager: motionManager)
        self.swifty360View.setup(player: self.player, motionManager: motionManager)
        self.addSubview(self.swifty360View)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.reorientVerticalCameraAngle))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func reorientVerticalCameraAngle() {
        self.swifty360View.reorientVerticalCameraAngleToHorizon(animated: true)
    }

    // play
    private func play() {
        self.swifty360View.player.play()
    }

    // stop
    private func stop() {
        self.swifty360View.player.pause()
    }

    // reset
    private func reset() {
        self.searchTime(time: .zero)
    }

    // jump to time
    private func searchTime(time: Double) {
        let sec = CMTimeMakeWithSeconds(Float64(time), preferredTimescale: Int32(NSEC_PER_SEC))
        self.swifty360View.player.seek(to: sec)
        self.checkPlayerState()
    }

    // seek to time
    private func moveTime(time: Double) {
        let current = self.swifty360View.player.currentTime()
        let sec = CMTimeMakeWithSeconds(Float64(time), preferredTimescale: Int32(NSEC_PER_SEC))
        self.swifty360View.player.seek(to: current + sec)
        self.checkPlayerState()
    }

    // time update
    private func updateTime() {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }

            let duration = Int(CMTimeGetSeconds(time))
            let durationSeconds = duration % 60
            let durationMinutes = duration / 60
            let durationString = String(format: "%02d:%02d", durationMinutes, durationSeconds)

            let itemDuration = self.player.currentItem?.duration
            let second = CMTimeGetSeconds(itemDuration ?? CMTimeMake(value: 0, timescale: 1))
            if second.isNaN {
                return
            }
            let total = Int(second)
            let totalSeconds = total % 60
            let totalMinutes = total / 60
            let totalString = String(format: "%02d:%02d", totalMinutes, totalSeconds)

            self.channel.invokeMethod("test", arguments: ["duration": durationString, "total": totalString])
        }
    }
}



extension Video360View {

    // 첫 생성 및 재생 시간 이동 시 영상 로드 시간동안 상태를 확인하여 재생이 가능할때 바로 시작
    private func checkPlayerState() {
        self.timer = Timer(timeInterval: 0.5,
                           target: self,
                           selector: #selector(self.check),
                           userInfo: nil,
                           repeats: true)
        RunLoop.main.add(self.timer!, forMode: .common)
    }

    @objc private func check() {
        guard let currentItem = self.player.currentItem,
              currentItem.status == AVPlayerItem.Status.readyToPlay,
              currentItem.isPlaybackLikelyToKeepUp,
              !self.player.isPlaying else { return }

        print("Playing")
        self.swifty360View.play()

        self.timer?.invalidate()
        self.timer = nil
    }
}



// MARK: - AVPlayer Extension
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
