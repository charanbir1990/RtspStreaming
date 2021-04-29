//
//  ViewController.swift
//  RTSP
//
//  Created by Charanbir Singh on 29/04/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollVw: UIScrollView!
    var video: RTSPPlayer?
    var timerProximity: RepeatingTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollVw.minimumZoomScale = 1.0
        scrollVw.maximumZoomScale = 10.0
        scrollVw.zoomScale = 1.0
        DispatchQueue.global().async {
            self.play()
        }
    }
    
    func play() {
        video = RTSPPlayer(video: "rtsp://admin:L254A730@192.168.0.101:554/cam/realmonitor?channel=1&subtype=0", usesTcp: true)
        if video == nil {fatalError("rtsp")}
        video?.outputWidth = 1920 //Int32(UIScreen.main.bounds.width)
        video?.outputHeight = 1080 //Int32(UIScreen.main.bounds.height)
        video?.seekTime(0.0)
//        video?.closeAudio()
        
        timerProximity = RepeatingTimer(timeInterval: 1.0/30.0)
        timerProximity?.eventHandler = { [weak self] () in
            self?.update()
        }
        timerProximity?.resume()
    }
    
    func update() {
        if(!(video?.stepFrame() ?? false)){
            timerProximity?.suspend()
            timerProximity = nil
            video?.closeAudio()
        }
        DispatchQueue.main.async {
            self.imageView.image = self.video?.currentImage
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

class RepeatingTimer {

    let timeInterval: TimeInterval
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now()+self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    var eventHandler: (() -> Void)?

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }

    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}
