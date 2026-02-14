//
//  HNPortraitControlView.swift
//  Acht
//
//  Created by forkon on 2018/9/6.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class HNPortraitControlView: PassThroughView, HNPlayerControlProtocol, RecordingStateToggleable, Highlightable, TransferRateDisplayable, PlayerViewModeToggleable {
    private let onKeyPath = "on"
    let config = ApplyCameraConfigMK()
    static let playBarHeight: CGFloat = 36.0

    @IBOutlet weak var floatButtonsStackView: UIStackView!
    
    @IBOutlet weak var playBar: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var resolutionButton: UIButton!
    @IBOutlet weak var dmsFaceButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var viewModeButton: UIButton!
    @IBOutlet weak var transferRateLabel: UILabel!
    @IBOutlet weak var highlightButton: UIButton!
    @IBOutlet weak var highlightCard: HighlightCard!
    @IBOutlet weak var recordingStackView: UIStackView!
    @IBOutlet weak var recordingSwitch: UISwitch!
    @IBOutlet weak var recordingStateLabel: UILabel!
    @IBOutlet weak var micButton: UIButton!

    weak var player: PlayerPanel?

    private var currentStreamNum = Int(1)

    #if !FLEET
    var micButtonTrackingStateObservation: NSKeyValueObservation?
    #endif

    deinit {
        recordingSwitch.removeObserver(self, forKeyPath: onKeyPath)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        recordingSwitch.addObserver(self, forKeyPath: onKeyPath, options: .new, context: nil)

        #if !FLEET
        micButtonTrackingStateObservation = micButton.observe(\.isTracking) { [weak self] (button, change) in
            self?.player?.onMicButtonTouchStateChange(button)
        }
        #endif
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == onKeyPath && (object as? UISwitch) == recordingSwitch {
            recordingStateLabel.text = recordingSwitch.isOn ? NSLocalizedString("Recording", comment: "Recording") : NSLocalizedString("rec_idle", comment: "Idle")
        }
    }
    
    func updateUI() {
        guard let player = player else {
            return
        }
   //     print("player.viewMode",player.viewMode.renderMode)
        micButton.isHidden = true

        switch player.playSource {
        case .localLive:
            playButton.isHidden = true
            transferRateLabel.isHidden = true
            highlightButton.isHidden = false
            resolutionButton.isHidden = true
            viewModeButton.isHidden = false

            #if FLEET
            recordingStackView.isHidden = true
            #else
            recordingStackView.isHidden = false
            #endif
        case .remoteLive:
            playButton.isHidden = true
            transferRateLabel.isHidden = true
            recordingStackView.isHidden = true
            highlightButton.isHidden = true
            resolutionButton.isHidden = true
            viewModeButton.isHidden = true //hidden
        case .localPlayback:
            playButton.isHidden = false
            transferRateLabel.isHidden = true
            recordingStackView.isHidden = true
            highlightButton.isHidden = false
            //resolutionButton.isHidden = false
            viewModeButton.isHidden = false
        case .remotePlayback:
            playButton.isHidden = false
            transferRateLabel.isHidden = true
            recordingStackView.isHidden = true
            highlightButton.isHidden = true
            resolutionButton.isHidden = true
            viewModeButton.isHidden = true // hidden
        case .offline:
            playButton.isHidden = true
            transferRateLabel.isHidden = true
            recordingStackView.isHidden = true
            highlightButton.isHidden = true
            resolutionButton.isHidden = true
            viewModeButton.isHidden = true
        case .none:
            break
        }
        
        switch player.playState {
        case .unloaded:
            playButton.setPlayAppearance()
        case .stopped:
            if player.playSource == .remoteLive {
                playButton.isHidden = true
                transferRateLabel.isHidden = true
            }
            playButton.setPlayAppearance()
        case .playing:
            if player.playSource == .remoteLive {
                playButton.isHidden = false
                transferRateLabel.isHidden = false

                #if !FLEET
                micButton.isHidden = false
                #endif
            }
            playButton.setPauseAppearance()
        case .paused:
            if player.playSource == .remoteLive {
                playButton.isHidden = true
                transferRateLabel.isHidden = true
            }
            playButton.setPlayAppearance()
        case .buffering:
            if player.playSource == .remoteLive {
                playButton.isHidden = false
                transferRateLabel.isHidden = true

                #if !FLEET
                micButton.isHidden = false
                #endif
            }
            playButton.setPauseAppearance()
        case .seeking:
            playButton.setPauseAppearance()
        case .completed, .error:
            playButton.setPlayAppearance()
        }
        
        switch player.viewMode {
        case .frontBack:
            viewModeButton.setViewModePanoramaAppearance()
            resolutionButton.setResolutionAppearance(resolution: player.currentResolution)
        case .panorama:
            viewModeButton.setViewModeFrontBackAppearance()
            resolutionButton.setResolutionAppearance(resolution: player.currentResolution)
        case .raw:
            viewModeButton.setViewModeShowDMSAppearance(show: player.showDMSInfo)
            resolutionButton.setResolutionAppearance()
        }

        if player.isHighlightCardShown {
            highlightCard.isHidden = false
            highlightButton.isHidden = true
        } else {
            highlightCard.isHidden = true
            highlightButton.isHidden = !player.canHighlight
        }
        
        if player.fullScreen {
            fullScreenButton.setExitFullScreenAppearance()
        } else {
            fullScreenButton.setFullScreenAppearance()
        }

        #if FLEET
        let shouldShowDmsFaceButton = (
            (
                UserSetting.shared.debugEnabled
                    && (AccountControlManager.shared.isLogin)
            )
            && (
                /*player.playSource == .localLive
                    && */player.viewMode == .raw
            )
        )
        #else
        let shouldShowDmsFaceButton = (UserSetting.shared.debugEnabled && (player.playSource == .localLive && player.viewMode == .raw))
        #endif

//        if shouldShowDmsFaceButton {
//            dmsFaceButton.isHidden = false
//        }
//        else {
//            dmsFaceButton.isHidden = true
//        }
    }
    
    func hideDMSFaceButton(hide: Bool){
        dmsFaceButton.isHidden = hide
    }
    
//    func
    
    func showControlView() {
        if player?.isPlayBarCoveredVideo == true {
            playBar.alpha = 1.0
        }
//        floatButtonsStackView.alpha = 1.0
    }
    
    func hideControlView() {
        if player?.isPlayBarCoveredVideo == true {
            playBar.alpha = 0.0
        }
//        floatButtonsStackView.alpha = 0.0
    }

    func showResolutionButton(_ show: Bool, streams : Int) {
        resolutionButton.isHidden = !show
        currentStreamNum = streams
        if let player = player {
            if player.viewMode == .raw {
                resolutionButton.setResolutionAppearance()
            }
            else {
                resolutionButton.setResolutionAppearance(resolution: player.currentResolution)
            }
        }
    }

    func showViewModeButton(_ show: Bool) {
        viewModeButton.isEnabled = show
    }
    
    var timer: Timer?
    
       

        
}

extension HNPortraitControlView {
    
    
    

    
    @IBAction func screenShortTapped(_ sender: UIButton) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
           // print("clicked button")
            if let image = self.player?.videoPlayer?.getRawImageView().image {
                if let stringBase64 =  ImageConverter().imageToBase64(image) {
            
                    self.config.camera =   UnifiedCameraManager.shared.local
                    print("stringBase64",stringBase64)
                    self.config.buildImage(dict: ["imgBase64" : stringBase64])
                }
            }
        })
        
       
           
            
       
        
       
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        player?.onPlay()
    }
    
    @IBAction func fullScreenButtonTapped(_ sender: UIButton) {
        player?.onFullScreen()
    }
    
    @IBAction func resolutionButtonTapped(_ sender: UIButton) {
        player?.onSwitchResoluttion()
    }
    
    @IBAction func viewModeButtonTapped(_ sender: UIButton) {
        if player?.viewMode == .raw {
            viewModeButton.setViewModeShowDMSAppearance(show: !player!.showDMSInfo)
        }
        player?.onSwitchViewMode()
    }
    
    @IBAction func highlightButtonTapped(_ sender: UIButton) {
        player?.onHighlight()
    }
    
    @IBAction func highlightCardTapped(_ sender: UIButton) {
        player?.onHighlightCard()
    }

    @IBAction func dmsFaceButtonTapd (_ sender: UIButton) {
        player?.onDMSFace()
    }

    @IBAction func micButtonTouchStateDidChange(_ sender: UIButton) {
    }

}

extension HNPortraitControlView: NibCreatable {}


extension UIView {

    func takeScreenshot() -> UIImage {

        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}
