//
//  AllCamViewController.swift
//  RTSP
//
//  Created by Charanbir Singh on 30/04/21.
//

import UIKit

class AllCamViewController: UIViewController {
    @IBOutlet weak var tableVw: UITableView!
    @IBOutlet weak var constraintHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollVw: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableVw.dataSource = self
        tableVw.reloadData()
    }

}

extension AllCamViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DispatchQueue.main.async {
            self.constraintHeight.constant = tableView.contentSize.height
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.constraintHeight.constant = tableView.contentSize.height
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCam") as! TableViewCellCam
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            cell.url = "rtsp://admin:L254A730@192.168.0.101:554/cam/realmonitor?channel=1&subtype=0"
        } else if indexPath.row == 1 {
            cell.url = "rtsp://admin:admin123456@192.168.0.100:8554/profile0"
        }
        return cell
    }
    
    
}

class TableViewCellCam: UITableViewCell {
    @IBOutlet weak var imageVw: UIImageView!
    @IBOutlet weak var scrollVw: UIScrollView!
    
    var video: RTSPPlayer?
    var timerProximity: RepeatingTimer?
    
    var url: String? {
        didSet {
            if video == nil {
                scrollVw.delegate = self
                scrollVw.minimumZoomScale = 1.0
                scrollVw.maximumZoomScale = 10.0
                scrollVw.zoomScale = 1.0
                DispatchQueue.global().async {
                    if let url = self.url {
                        self.play(url: url)
                    }
                }
            }
        }
    }
    
    func play(url: String) {
        video = RTSPPlayer(video: url, usesTcp: true)
        if video == nil {fatalError("rtsp")}
        video?.outputWidth = 1920
        video?.outputHeight = 1080
        video?.seekTime(0.0)
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
            self.imageVw.image = self.video?.currentImage
        }
    }
}

extension TableViewCellCam: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageVw
    }
}
