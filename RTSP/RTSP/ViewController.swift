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
    var video: RTSPPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollVw.minimumZoomScale = 1.0
        scrollVw.maximumZoomScale = 10.0
        scrollVw.zoomScale = 1.0
        video = RTSPPlayer(video: "rtsp://admin:L254A730@192.168.0.101:554/cam/realmonitor?channel=1&subtype=0", usesTcp: true)
        if video == nil {return}
        video.outputWidth = 1920 //Int32(UIScreen.main.bounds.width)
        video.outputHeight = 1080 //Int32(UIScreen.main.bounds.height)
        video.seekTime(0.0)
        
        let timer = Timer.scheduledTimer(timeInterval: 1.0/30.0, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        timer.fire()
    }
    
  @objc func update(timer: Timer) {
        if(!video.stepFrame()){
            timer.invalidate()
            video.closeAudio()
        }
        imageView.image = video.currentImage
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
