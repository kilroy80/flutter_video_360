import UIKit
import AVKit
import Swifty360Player

class VRViewController: UIViewController {

//    var swifty360ViewController: Swifty360ViewController!
    var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black

        let videoURL = URL(string: "https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560.m3u8")!
        player = AVPlayer(url: videoURL)

        let motionManager = Swifty360MotionManager.shared

        let swifty360View = Swifty360View(withFrame: view.bounds,
                                             player: player,
                                      motionManager: motionManager)
        swifty360View.setup(player: player, motionManager: motionManager)
        view.addSubview(swifty360View)

        // delay 5 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.player.play()
        }

//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reorientVerticalCameraAngle))
//        swifty360ViewController.view.addGestureRecognizer(tapGestureRecognizer)
    }

//    @objc func reorientVerticalCameraAngle() {
//        swifty360ViewController.reorientVerticalCameraAngleToHorizon(animated: true)
//    }

}
