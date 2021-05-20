import UIKit
import AVKit
import Swifty360Player

class VRViewController: UIViewController {

//    var swifty360ViewController: Swifty360ViewController!
    var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black

        guard let videoURL = URL(string: "https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560.m3u8") else { return }
        player = AVPlayer(url: videoURL)

        let motionManager = Swifty360MotionManager.shared

        let swifty360View = Swifty360View(withFrame: view.bounds,
                                             player: player,
                                      motionManager: motionManager)
        swifty360View.setup(player: player, motionManager: motionManager)
        view.addSubview(swifty360View)

        // delay 5 second
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            self.player.play()
//        }
        
        player.play()
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { (time) in
            if let currentItem = self.player.currentItem {
                if currentItem.status == AVPlayerItem.Status.readyToPlay {
                        if currentItem.isPlaybackLikelyToKeepUp {
                            if (self.player.rate == 0) {
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

//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reorientVerticalCameraAngle))
//        swifty360ViewController.view.addGestureRecognizer(tapGestureRecognizer)
    }

//    @objc func reorientVerticalCameraAngle() {
//        swifty360ViewController.reorientVerticalCameraAngleToHorizon(animated: true)
//    }

}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
