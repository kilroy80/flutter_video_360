import Flutter
import UIKit
import AVKit

#if USE_SPM_EXTERNAL_FRAMEWORK
import Swifty360Player
#endif

class Video360View: UIView {

    private let channel: FlutterMethodChannel

    private var timer: Timer?
    private var player: AVPlayer?
    private var swifty360View: Swifty360View?
    private var playbackEndObserver: NSObjectProtocol?
    private var isDisposed = false
    
//    private var width: Double?
//    private var height: Double?
    
//    private var duration: Int?
//    private var totalDuration: CMTime?
//    private var total: Int?
//    private var isPlaying: Bool?
    
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
            guard let self = self else {
                result(FlutterError(code: "disposed", message: "Video360View was disposed", details: nil))
                return
            }

            switch call.method {
            case "init":
                guard let argMaps = call.arguments as? Dictionary<String, Any>,
                      let url = argMaps["url"] as? String,
                      !url.isEmpty,
                      let videoURL = URL(string: url),
                      let isRepeat = argMaps["isRepeat"] as? Bool,
                      let width = argMaps["width"] as? Double,
                      let height = argMaps["height"] as? Double else {
                    result(FlutterError(code: call.method, message: "Missing argument", details: nil))
                    return
                }

                self.initView(videoURL: videoURL, width: width, height: height)
//                self.updateTime()

//                 if isAutoPlay {
//                     self.checkPlayerState()
//                 }

                if isRepeat, let currentItem = self.player?.currentItem {
                    self.playbackEndObserver = NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemDidPlayToEndTime,
                        object: currentItem,
                        queue: .main
                    ) { [weak self] _ in
                        self?.reset()
                    }
                }
                result(nil)

            case "dispose":
                result(nil)
                self.dispose()

            case "play":
                self.play()
                self.checkPlayerState()
                result(nil)
               
            case "stop":
                self.stop()
                result(nil)

            case "reset":
                self.reset()
                result(nil)

            case "jumpTo":
                guard let argMaps = call.arguments as? Dictionary<String, Any>,
                      let time = argMaps["millisecond"] as? Double else {
                    result(FlutterError(code: call.method, message: "Missing argument", details: nil))
                    return
                }
                self.jumpTo(second: time / 1000.0)
                result(nil)

            case "seekTo":
                guard let argMaps = call.arguments as? Dictionary<String, Any>,
                      let time = argMaps["millisecond"] as? Double else {
                    result(FlutterError(code: call.method, message: "Missing argument", details: nil))
                    return
                }
                self.seekTo(second: time / 1000.0)
                result(nil)

            case "onPanUpdate":
                guard let argMaps = call.arguments as? Dictionary<String, Any>,
                      let isStart = argMaps["isStart"] as? Bool,
                      let swifty360View = self.swifty360View,
                      let x = argMaps["x"] as? Double,
                      (0 ... Double(swifty360View.frame.maxX)) ~= x,
                      let y = argMaps["y"] as? Double,
                      (0 ... Double(swifty360View.frame.maxY)) ~= y else {
                    result(FlutterError(code: call.method, message: "Missing argument", details: nil))
                    return
                }
                let point = CGPoint(x: x, y: y)
                swifty360View.cameraController.handlePan(isStart: isStart, point: point)
                result(nil)

            case "currentPosition":
                let position = self.player?.currentItem?.currentTime() ?? .zero
                let seconds = CMTimeGetSeconds(position)
                result(seconds.isFinite ? Int(seconds * 1000) : 0)
            
            case "duration":
                let duration = self.player?.currentItem?.asset.duration ?? .zero
                let seconds = CMTimeGetSeconds(duration)
                result(seconds.isFinite ? Int(seconds * 1000) : 0)
                
            case "playing":
                let isPlaying = self.player?.isPlaying
                result(isPlaying)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // 360View Init
    private func initView(videoURL: URL, width: Double, height: Double) {
        self.cleanUpPlayback()
        self.player = AVPlayer(url: videoURL)
        let motionManager = Swifty360MotionManager.shared
        self.swifty360View = Swifty360View(
            withFrame: CGRect(x: 0.0, y: 0.0, width: width, height: height),
            player: self.player!,
            motionManager: motionManager)
        self.swifty360View?.setup(player: self.player!, motionManager: motionManager)
        if let swifty360View = self.swifty360View {
            self.addSubview(swifty360View)
        }
    }

    //dispose
    func dispose() {
        guard !self.isDisposed else { return }
        self.isDisposed = true
        self.channel.setMethodCallHandler(nil)
        self.cleanUpPlayback()
    }

    private func cleanUpPlayback() {
        self.timer?.invalidate()
        self.timer = nil

        if let playbackEndObserver = self.playbackEndObserver {
            NotificationCenter.default.removeObserver(playbackEndObserver)
            self.playbackEndObserver = nil
        }

        self.player?.pause()
        self.swifty360View?.tearDown()
        self.swifty360View?.removeFromSuperview()
        self.swifty360View = nil
        self.player = nil
    }

    // play
    private func play() {
        self.player?.play()
    }

    // stop
    private func stop() {
        self.stopReadyTimer()
        self.player?.pause()
    }

    // reset
    private func reset() {
        self.jumpTo(second: .zero)
    }

    // jumpTo
    private func jumpTo(second: Double) {
        let sec = CMTimeMakeWithSeconds(Float64(second), preferredTimescale: Int32(NSEC_PER_SEC))
        self.player?.seek(to: sec)
        self.checkPlayerState()
    }

    // seekTo
    private func seekTo(second: Double) {
        guard let current = self.swifty360View?.player.currentTime() else { return }
        let sec = CMTimeMakeWithSeconds(Float64(second), preferredTimescale: Int32(NSEC_PER_SEC))
        self.player?.seek(to: current + sec)
        self.checkPlayerState()
    }

    // updateTime
//    private func updateTime() {
//        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//        self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
//            guard let self = self else { return }
//
//            let duration = Int(Float(Int(time.value)) * 0.000001)
//            let totalDuration = self.player.currentItem?.duration ?? .zero
//            let total = Int(totalDuration.value)
//            let isPlaying = self.player?.isPlaying
//            
//            self.channel.invokeMethod("updateTime", arguments: ["duration": duration, "total": total, "isPlaying": isPlaying])
//        }
//    }

    // check player state - for auto play
    private func checkPlayerState() {
        guard self.timer == nil else { return }

        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkReadyToPlay()
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    @objc private func checkReadyToPlay() {
        guard let player = self.player, let currentItem = player.currentItem else {
            self.stopReadyTimer()
            return
        }

        if player.isPlaying {
            self.stopReadyTimer()
            return
        }

        if currentItem.status == .failed {
            self.stopReadyTimer()
            return
        }

        guard currentItem.status == .readyToPlay,
              currentItem.isPlaybackLikelyToKeepUp else { return }

        self.play()
        self.stopReadyTimer()
    }

    private func stopReadyTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

    deinit {
        self.channel.setMethodCallHandler(nil)
        self.cleanUpPlayback()
    }
}

// MARK: - AVPlayer Extension
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
