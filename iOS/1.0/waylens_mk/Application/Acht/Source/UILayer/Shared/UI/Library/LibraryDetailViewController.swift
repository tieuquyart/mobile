//
//  LibraryDetailViewController.swift
//  Acht
//
//  Created by Chester Shen on 9/26/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
#if useMixpanel
import Mixpanel
#endif
import WaylensPiedPiper

class LibraryDetailViewController: BaseViewController {
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet weak var indicator: UIView!
    @IBOutlet weak var infoLabel: UILabel!
//    @IBOutlet weak var playerHeight: NSLayoutConstraint!
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var topBar: UIView!
    
    var clip: SavedClip? {
        willSet {
            reset()
        }
        
        didSet {
            refresh()
        }
    }
    var playerPanel = PlayerPanelCreator.createTranslucentPlayerPanel()

    override var shouldAutorotate: Bool{
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .landscapeRight
        //        if playerPanel.viewMode == .frontBack {
        //            return [.landscapeRight]
        //        }
        //        return [.portrait, .landscapeRight]
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        get {
            return true
        }
    }
    
    static func createViewController() -> LibraryDetailViewController {
        let vc = UIStoryboard(name: "Library", bundle: nil).instantiateViewController(withIdentifier: "LibraryDetailViewController")
        return vc as! LibraryDetailViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        playerPanel.addToParentViewController(self, superView: playerContainer)
        playerPanel.delegate = self
    }

    override func applyTheme() {
        super.applyTheme()
        view.backgroundColor = .black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerPanel.showPlayerControls()
        playVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerPanel.shutdown()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playVideo() {
        guard let clip = clip, let url = clip.url else { return }
        if playerPanel.playState == .paused {
            playerPanel.resume()
        } else {
            playerPanel.playSource = .remotePlayback
            playerPanel.duration = clip.duration
            playerPanel.setFacedown(clip.facedown)
            playerPanel.playVideo(url)
        }
        playerPanel.supportViewMode = clip.needDewarp
    }

    func reset() {
        defaultOrientation()
        if !isViewLoaded { return }
        playerPanel.reset()
        playerPanel.fullScreen = true
    }
    
    func defaultOrientation() {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    
    func refresh() {
        if !isViewLoaded { return }
        guard let clip = clip else {
            infoLabel.text = nil
            indicator.backgroundColor = .clear
            return
        }
        infoLabel.text = "\(clip.startDate.toHumanizedDateTimeString())"
        indicator.backgroundColor = clip.indicatorColor
        if let thumbnailPath = clip.thumbnailUrl {
            let thumbnailUrl = URL(fileURLWithPath: thumbnailPath)
            // todo, dewarp
            playerPanel.thumbnail.hn_setImage(url: thumbnailUrl, facedown: clip.facedown, dewarp: clip.needDewarp)
            if !clip.needDewarp {
                playerPanel.thumbnail.contentMode = .scaleAspectFit
            }
        }
        playerPanel.supportViewMode = clip.needDewarp
    }
    
    @IBAction func onClose(_ sender: Any) {
        if !UIApplication.shared.statusBarOrientation.isPortrait {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("The video will be deleted from your phone's storage", comment: "The video will be deleted from your phone's storage"), preferredStyle: .actionSheetOrAlertOnPad)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete"), style: .destructive, handler: { (_) in
            MixpanelHelper.track(event: "Delete album video on detail")
            self.playerPanel.shutdown()
            SavedClipManager.shared.removeClip(self.clip!)
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { (_) in
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onExport(_ sender: Any) {
//        let editClip = EditableClip(clip!)
//        let vc = ExportSessionViewController.createViewController(clip: editClip, camera: nil, exportDestination: .photoLibrary)
//        let nc = BaseNavigationController(rootViewController: vc)
//        vc.addCloseButton()
//        vc.modalPresentationStyle = .fullScreen
//        present(nc, animated: true, completion: nil)

//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheetOrAlertOnPad)
//        alert.addAction(UIAlertAction(title: "Export to Photo Library", style: .default, handler: { (_) in
//            MixpanelHelper.track(event: "Export album video on detail")
//            let vc = HNTranscodeViewController.createViewController()
//            guard let urlStr = self.clip?.url else { return }
//            vc.movieURL = URL(fileURLWithPath: urlStr)
//            vc.clip = self.clip
//            self.playerPanel.stop()
//            self.playerPanel.playState = .unloaded
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        present(alert, animated: true, completion: nil)
    }
}

// MARK: - PlayerPanel Delegate
extension LibraryDetailViewController: HNPlayerPanelDelegate {
    func onViewMode(_ viewMode: HNViewMode) {
        if viewMode == .frontBack && UIApplication.shared.statusBarOrientation.isPortrait {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    
    func onPlay(_ play: Bool) {
        if play {
            playVideo()
        } else {
            playerPanel.pause()
        }
    }
    
    func showControls(show:Bool, duration: TimeInterval) {
        if show {
//            topSpace.constant = 0
            topBar.alpha = 1.0
        } else {
//            topSpace.constant = -60
            topBar.alpha = 0.0
        }
//        UIView.animate(withDuration: duration, animations: {
//            self.view.layoutIfNeeded()
//        })
    }
}
