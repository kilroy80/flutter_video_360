import Flutter
import UIKit
import AVKit

class Video360View: UIView, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {}

    private let channel: FlutterMethodChannel

    private var timer: Timer?
    private var player: AVPlayer!
    private var swifty360View: Swifty360View!

    init(viewId: String, messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(name: viewId, binaryMessenger: messenger)

        super.init(frame: .zero)

        self.addChannel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - Interface
extension Video360View {

    // flutter channel
    private func addChannel() {
        self.channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }

            switch call.method {
            case "init":
                guard let argMaps = call.arguments as? Dictionary<String, Any>,
                      let url = argMaps["url"] as? String,
                      let videoURL = URL(string: url),
                      let isAutoPlay = argMaps["isAutoPlay"] as? Bool,
                      let isRepeat = argMaps["isRepeat"] as? Bool,
                      let width = argMaps["width"] as? Double,
                      let height = argMaps["height"] as? Double else {
                    result(FlutterError(code: call.method, message: "Missing argument", details: nil))
                    return
                }

                self.initView(videoURL: videoURL, width: width, height: height)
                self.updateTime()

                if isAutoPlay {
                    self.checkPlayerState()
                }

                if isRepeat {
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(self.playerFinish(noti:)),
                                                           name: .AVPlayerItemDidPlayToEndTime,
                                                           object: nil)
                }

            case "dispose":
                self.dispose()

            case "play":
                self.play()

            case "stop":
                self.stop()

            case "reset":
                self.reset()

            case "jumpTo":
                guard let argMaps = call.arguments as? Dictionary<String, Any>,
                      let time = argMaps["millisecond"] as? Double else {
                    result(FlutterError(code: call.method, message: "Missing argument", details: nil))
                    return
                }
                self.jumpTo(second: time / 1000.0)

            case "seekTo":
                guard let argMaps = call.arguments as? Dictionary<String, Any>,
                      let time = argMaps["millisecond"] as? Double else {
                    result(FlutterError(code: call.method, message: "Missing argument", details: nil))
                    return
                }
                self.seekTo(second: time / 1000.0)

            case "onPanUpdate":
                guard let argMaps = call.arguments as? Dictionary<String, Any>,
                      let isStart = argMaps["isStart"] as? Bool,
                      let x = argMaps["x"] as? Double,
                      (0 ... Double(self.swifty360View.frame.maxX)) ~= x,
                      let y = argMaps["y"] as? Double,
                      (0 ... Double(self.swifty360View.frame.maxY)) ~= y else {
                    result(FlutterError(code: call.method, message: "Missing argument", details: nil))
                    return
                }
                let point = CGPoint(x: x, y: y)
                self.swifty360View.cameraController.handlePan(isStart: isStart, point: point)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // 360View Init
    private func initView(videoURL: URL, width: Double, height: Double) {
        self.player = AVPlayer(url: videoURL)
        let motionManager = Swifty360MotionManager.shared
        self.swifty360View = Swifty360View(withFrame: CGRect(x: 0.0, y: 0.0, width: width, height: height),
                                           player: self.player,
                                           motionManager: motionManager)
        self.swifty360View.setup(player: self.player, motionManager: motionManager)
        self.addSubview(self.swifty360View)
    }

    // repeat
    @objc private func playerFinish(noti: NSNotification) {
        self.reset()
    }

    //dispose
    func dispose() {
        // auto repeat notification remove
        NotificationCenter.default.removeObserver(self)
    }

    // play
    private func play() {
        self.player.play()
    }

    // stop
    private func stop() {
        self.player.pause()
    }

    // reset
    private func reset() {
        self.jumpTo(second: .zero)
    }

    // jumpTo
    private func jumpTo(second: Double) {
        let sec = CMTimeMakeWithSeconds(Float64(second), preferredTimescale: Int32(NSEC_PER_SEC))
        self.player.seek(to: sec)
        self.checkPlayerState()
    }

    // seekTo
    private func seekTo(second: Double) {
        let current = self.swifty360View.player.currentTime()
        let sec = CMTimeMakeWithSeconds(Float64(second), preferredTimescale: Int32(NSEC_PER_SEC))
        self.player.seek(to: current + sec)
        self.checkPlayerState()
    }

    // updateTime
    private func updateTime() {
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }

            let duration = Int(Float(Int(time.value)) * 0.000001)
            let totalDuration = self.player.currentItem?.duration ?? .zero
            let total = Int(totalDuration.value)
            let isPlaying = self.player?.isPlaying

            self.channel.invokeMethod("updateTime", arguments: ["duration": duration, "total": total, "isPlaying": isPlaying])
        }
    }

    // check player state - for auto play
    private func checkPlayerState() {
        guard self.timer == nil else { return }

        self.timer = Timer(timeInterval: 0.5,
                           target: self,
                           selector: #selector(self.checkReadyToPlay),
                           userInfo: nil,
                           repeats: true)
        RunLoop.main.add(self.timer!, forMode: .common)
    }

    @objc private func checkReadyToPlay() {
        guard self.player != nil,
              let currentItem = self.player.currentItem,
              currentItem.status == AVPlayerItem.Status.readyToPlay,
              currentItem.isPlaybackLikelyToKeepUp,
              !self.player.isPlaying else { return }

        self.play()

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
