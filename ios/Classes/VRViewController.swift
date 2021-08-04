import UIKit
import AVKit
import Swifty360Player

class VRViewController: UIViewController {
    
    var url: URL
    var swifty360View: Swifty360View!
    var player: AVPlayer!
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        self.addPlayer()
        self.addPlayerObserver()
    }
    
    
    
}



// MARK: - Interface

extension VRViewController {
    
    // 저정한 시간에서 시작
    public func setPlayTime(time: Double) {
        let sec = CMTimeMakeWithSeconds(Float64(time), preferredTimescale: Int32(NSEC_PER_SEC))
        self.swifty360View.player.seek(to: sec)
    }
    
    // 현재 기준에서 time 만큼 이동
    public func setMove(time: Double) {
        let current = swifty360View.player.currentTime()
        let sec = CMTimeMakeWithSeconds(Float64(time), preferredTimescale: Int32(NSEC_PER_SEC))
        self.swifty360View.player.seek(to: current + sec)
    }
    
    // 음소거
    public func setMuted(isState: Bool) {
        self.swifty360View.player.isMuted = isState
    }
    
    // 재생속도
    public func setRate(rate: Double) {
        self.swifty360View.player.rate = Float(rate)
    }
    
    // true - 재생, false - 일시 정지
    public func setPlayerState(isState: Bool) {
        isState ?
            self.swifty360View.player.pause() :
            self.swifty360View.player.play()
    }
}



// MARK: - UI

extension VRViewController {
    
    // player 초기 세팅
    private func addPlayer() {
        self.player = AVPlayer(url: url)
        let motionManager = Swifty360MotionManager.shared
        self.swifty360View = Swifty360View(withFrame: view.bounds,
                                           player: player,
                                           motionManager: motionManager)
        self.swifty360View.setup(player: player, motionManager: motionManager)
        self.view.addSubview(self.swifty360View)
    }
    
    // 0.5초마다 플레이어 상태를 확인함
    private func addPlayerObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            guard let self = self, let currentItem = self.player.currentItem else { return }
            
            switch currentItem.status {
            case .readyToPlay:
                if currentItem.isPlaybackLikelyToKeepUp {
                    guard !self.player.isPlaying else { return }
                    print("Playing")
                    self.player.play()
                    
                } else if currentItem.isPlaybackBufferEmpty {
                    print("Buffer empty - show loader")
                    
                }  else if currentItem.isPlaybackBufferFull {
                    print("Buffer full - hide loader")
                    
                } else {
                    print("Buffering")
                }
                
            case .failed:
                print("Failed")
                
            case .unknown:
                print("Unknown")
                
            @unknown default:
                fatalError()
            }
        }
    }
    
    // 화면 손가락 제스쳐
    private func addGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reorientVerticalCameraAngle))
        self.swifty360View.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func reorientVerticalCameraAngle() {
        self.swifty360View.reorientVerticalCameraAngleToHorizon(animated: true)
        
    }
}



// MARK: - AVPlayer Extension

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
