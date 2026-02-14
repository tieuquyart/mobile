//
//  AlertDetailViewController.swift
//  Acht
//
//  Created by Chester Shen on 9/4/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class AlertDetailViewController: BaseViewController {
    @IBOutlet private weak var playerContainer: UIView!
    @IBOutlet private weak var indicator: UIView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var playerHeight: NSLayoutConstraint!
    @IBOutlet private weak var topSpace: NSLayoutConstraint!
    @IBOutlet private weak var topBar: UIView!
    @IBOutlet private weak var uploadingStatusView: AlertDetailUploadingStatusView!
    @IBOutlet weak var gotoCameraButton: UIButton!
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))

    private var isVideoUploading: Bool {
        return alert?.uploadStatus?.isUploading ?? false
    }

    private var shouldShowGotoCameraButton: Bool {
        if camera != nil {
            return true
        } else {
            return false
        }
    }

    private var viewIsAppeared: Bool = false

    var camera: UnifiedCamera? {
        if let cameraID = alert?.cameraID, let camera = UnifiedCameraManager.shared.cameraForSN(cameraID) {
            return camera
        } else {
            return nil
        }
    }

    var alert: AchtAlert? {
        willSet {
            reset()
        }
        
        didSet {
            refresh()

            if !isBeingPresented && viewIsAppeared {
                playVideo()
            }
        }
    }
    var playerPanel = PlayerPanelCreator.createAlertDetailPlayerPanel()
    
    static func createViewController() -> AlertDetailViewController {
        let vc = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertDetailViewController")
        return vc as! AlertDetailViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.setNeedsLayout()
        view.layoutIfNeeded()
        view.backgroundColor = .black
        view.addGestureRecognizer(tapGestureRecognizer)
        
        playerPanel.addToParentViewController(self, superView: playerContainer)
        playerPanel.delegate = self
        playerPanel.supportViewMode = alert?.needDewarp ?? true

        #if FLEET
        gotoCameraButton.isHidden = true
        #else
        let gotoCameraButtonTitle = isVideoUploading ? NSLocalizedString("Go Live", comment: "Go Live") : NSLocalizedString("Watch Detail", comment: "Watch Detail")
        gotoCameraButton.set(image: #imageLiteral(resourceName: "btn_settings_list_next"), title: gotoCameraButtonTitle, titlePosition: UIButton.Position.left, additionalSpacing: 4.0, state: UIControl.State.normal)
        #endif

        reset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)

        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideo()
        viewIsAppeared = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerPanel.shutdown()
        viewIsAppeared = false
    }

    override var shouldAutorotate: Bool{
        return !isVideoUploading
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait, .landscapeRight]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let isPortrait = UIApplication.shared.statusBarOrientation == .portrait

        playerPanel.fullScreen = isPortrait
        if isPortrait {
            self.playerHeight.constant = UIScreen.main.bounds.width;
        } else {
            self.playerHeight.constant = UIScreen.main.bounds.height * 9/16;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func playVideo() {
        guard let alert = alert else { return }
        let url = alert.videoUrl
        if url.hasPrefix("rtmp") { // live
            playerPanel.setFacedown(alert.facedown)
            playerPanel.playRemoteLive(url)
        } else {
            if playerPanel.playState == .paused {
                playerPanel.resume()
            } else {
                playerPanel.playSource = .remotePlayback
                playerPanel.setFacedown(alert.facedown)
                playerPanel.playVideo(url)
            }
        }
    }
    
    private func reset() {
        if !isViewLoaded { return }
        gotoCameraButton.isHidden = true
        uploadingStatusView.isHidden = true
        playerPanel.reset()
        if UIApplication.shared.statusBarOrientation == .portrait {
            playerPanel.fullScreen = false
            playerHeight.constant = view.bounds.width * 9 / 16
            if UIDevice.current.orientation != .portrait {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        } else {
            playerPanel.fullScreen = true
            playerHeight.constant = view.bounds.height
            if UIDevice.current.orientation == .portrait {
                UIDevice.current.setValue(UIApplication.shared.statusBarOrientation.rawValue, forKey: "orientation")
            }
        }
    }
    
    private func refresh() {
        if !isViewLoaded { return }
        guard let alert = alert else {
            infoLabel.text = nil
            indicator.backgroundColor = .clear
            playerPanel.supportViewMode = true
            return
        }

        infoLabel.text = "\(alert.createTime.toHumanizedDateTimeString())     \(alert.sender)"
        #if FLEET
        indicator.backgroundColor = alert.eventType.color
        #else
        indicator.backgroundColor = alert.alertType.color
        #endif
        if let thumbnailUrl = URL(string: alert.thumbnailUrl) {
            CacheManager.shared.imageFetcher.get(thumbnailUrl).onSuccess { [weak self] (image) in
                self?.playerPanel.rawThumbnail = image
                self?.playerPanel.setFacedown(alert.facedown)
            }
        }
        
        // video exists or not
        if alert.videoUrl.isEmpty || alert.duration == 0.0 {
            playerPanel.controlView.subviews.forEach { (subview) in
                if let controlView = subview as? HNTranslucentControlView {
                    controlView.playButton.isHidden = true
                    controlView.progressSlider.isHidden = true
                    controlView.currentTimeLabel.isHidden = true
                }
            }
        } else {
            playerPanel.duration = alert.duration
            playerPanel.controlView.subviews.forEach { (subview) in
                if let controlView = subview as? HNTranslucentControlView {
                    controlView.playButton.isHidden = false
                    controlView.progressSlider.isHidden = false
                    controlView.currentTimeLabel.isHidden = false
                }
            }
        }

        if isVideoUploading {
            playerPanel.controlView.isHidden = true
            uploadingStatusView.isHidden = false
            playerContainer.bringSubviewToFront(uploadingStatusView)
        } else {
            playerPanel.controlView.isHidden = false
            uploadingStatusView.isHidden = true
            playerContainer.sendSubviewToBack(uploadingStatusView)
        }

        gotoCameraButton.isHidden = !shouldShowGotoCameraButton
    }
    
    @IBAction func onClose(_ sender: Any) {
        onFullScreen(false)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: view)

        if alert?.uploadStatus?.isUploading == false {
            if !playerContainer.frame.contains(tapLocation) {
                playerPanel.togglePlayerControlsDisplay()
            }
        }
    }

    @IBAction func gotoCameraButtonTapped(_ sender: Any) {
        if let camera = camera {
            showCameraDetailViewController(for: camera, scrollTo: alert?.createTime)
        }
    }
    
}

extension AlertDetailViewController: HNPlayerPanelDelegate {
    
//    func onFullScreen(_ full: Bool) {
//        if full {
//            if UIApplication.shared.statusBarOrientation == .portrait {
//                self.playerHeight.constant = self.view.bounds.width
//                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
//            }
//        } else {
//            if UIApplication.shared.statusBarOrientation != .portrait {
//                self.playerHeight.constant = self.view.bounds.height * 9/16
//                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
//            }
//        }
//    }
    func onFullScreen(_ full: Bool) {
//        layout(asLandscape: full)
        if full {
//            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            self.lockOrientation(.landscapeRight, andRotateTo: .landscapeRight)
        } else {
            self.lockOrientation(.portrait, andRotateTo: .portrait)
//            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
    

    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    func onPlay(_ play: Bool) {
        if play {
            playVideo()
        } else {
            playerPanel.pause()
        }
    }
    
    func showControls(show:Bool, duration: TimeInterval) {
        if !isVideoUploading {
            if show {
                topBar.alpha = 1.0
                gotoCameraButton.alpha = 1.0
            } else {
                topBar.alpha = 0.0
                gotoCameraButton.alpha = 0.0
            }
        }
    }
    
}

final class AlertDetailUploadingStatusView: UIView {

    private var statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
        statusLabel.text = NSLocalizedString("Events video uploading…", comment: "Events video uploading…")
        statusLabel.textColor = UIColor.white
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        return statusLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        addSubview(statusLabel)

        statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        statusLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

}
