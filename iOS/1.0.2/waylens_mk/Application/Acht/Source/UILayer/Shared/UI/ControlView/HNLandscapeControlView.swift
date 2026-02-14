//
//  HNLandScapeControlView.swift
//  Acht
//
//  Created by forkon on 2018/9/6.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class HNLandscapeControlView: PassThroughView, HNPlayerControlProtocol, RecordingStateToggleable, Highlightable, TransferRateDisplayable, TimeLineViewRequirable, PlayTimeDisplayable, TimePointInfoDisplayable, PlayerViewModeToggleable {

    
    private let onKeyPath = "on"

    @IBOutlet weak var playBar: UIView!
    @IBOutlet weak var floatButtonsStackView: UIStackView!
    @IBOutlet weak var timelineContainingView: UIView!
    @IBOutlet weak var recordingStackViewContainingView: UIView!
    @IBOutlet weak var transferRateLabelContainingView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var highlightButton: UIButton!
    @IBOutlet weak var resolutionButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var viewModeButton: UIButton!
    @IBOutlet weak var transferRateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var highlightCard: HighlightCard!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var recordingSwitch: UISwitch!
    @IBOutlet weak var recordingStateLabel: UILabel!
    @IBOutlet weak var recordingStackView: UIStackView!
    @IBOutlet weak var timePointInfoHUD: MultilineTextHUD!
    
    weak var player: PlayerPanel?

    var currentStreamNum = Int(1)

    deinit {
        recordingSwitch.removeObserver(self, forKeyPath: onKeyPath)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        recordingSwitch.addObserver(self, forKeyPath: onKeyPath, options: .new, context: nil)
    }
    
    func updateUI() {
        guard let player = player else {
            return
        }
        
        switch player.playSource {
        case .localLive:
            playButton.isHidden = true
            transferRateLabelContainingView.isHidden = true
            highlightButton.isHidden = false
            resolutionButton.isHidden = true
            viewModeButton.isHidden = false

            #if FLEET
            recordingStackViewContainingView.isHidden = true
            #else
            recordingStackViewContainingView.isHidden = false
            #endif
        case .remoteLive:
            playButton.isHidden = true
            transferRateLabelContainingView.isHidden = false
            recordingStackViewContainingView.isHidden = true
            highlightButton.isHidden = true
            resolutionButton.isHidden = true
            viewModeButton.isHidden = false
        case .localPlayback:
            playButton.isHidden = false
            transferRateLabelContainingView.isHidden = true
            recordingStackViewContainingView.isHidden = true
            highlightButton.isHidden = false
            //resolutionButton.isHidden = false
            viewModeButton.isHidden = false
        case .remotePlayback:
            playButton.isHidden = false
            transferRateLabelContainingView.isHidden = true
            recordingStackViewContainingView.isHidden = true
            highlightButton.isHidden = true
            resolutionButton.isHidden = true
            viewModeButton.isHidden = false
        case .offline:
            playButton.isHidden = true
            transferRateLabelContainingView.isHidden = true
            recordingStackViewContainingView.isHidden = true
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
            }
            playButton.setPauseAppearance()
        case .seeking:
            playButton.setPauseAppearance()
        case .completed, .error:
            playButton.setPlayAppearance()
        }
        
        switch player.viewMode {
        case .frontBack:
            viewModeButton.setViewModePanoramaFloatingAppearance()
            resolutionButton.setResolutionFloatingAppearance(resolution: player.currentResolution)
        case .panorama:
            viewModeButton.setViewModeFrontBackFloatingAppearance()
            resolutionButton.setResolutionFloatingAppearance(resolution: player.currentResolution)
        case .raw:
            viewModeButton.setViewModeShowDMSAppearance(show: player.showDMSInfo)
            resolutionButton.setResolutionFloatingAppearance()
        }

        if player.isHighlightCardShown {
            highlightCard.isHidden = false
            highlightButton.isHidden = true
        } else {
            highlightCard.isHidden = true
            highlightButton.isHidden = !player.canHighlight
        }
    }
    
    func hideDMSFaceButton(hide: Bool) {
    }
    
    func showControlView() {
        playBar.alpha = 1.0
        floatButtonsStackView.alpha = 1.0
        fullScreenButton.alpha = 1.0
        timeView.alpha = 0.0
    }
    
    func hideControlView() {
        playBar.alpha = 0.0
        floatButtonsStackView.alpha = 0.0
        fullScreenButton.alpha = 0.0
        timeView.alpha = 1.0
    }

    func showResolutionButton(_ show: Bool, streams : Int) {
        resolutionButton.isHidden = !show
        currentStreamNum = streams
    }
    func showViewModeButton(_ show: Bool) {
        viewModeButton.isEnabled = show
    }

    func addTimeLineView(_ timeLineView: CameraTimeLineHorizontalView) {
        timelineContainingView.addSubview(timeLineView)
        timeLineView.frame = timelineContainingView.bounds
        timeLineView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        timeLineView.translatesAutoresizingMaskIntoConstraints = true
        timeLineView.clipsToBounds = false
    }
    
    func removeTimeLineView() {
        timelineContainingView.subviews.forEach { (subview) in
            if subview is CameraTimeLineHorizontalView {
                subview.removeFromSuperview()
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case onKeyPath where (object as? UISwitch) == recordingSwitch:
            recordingStateLabel.text = recordingSwitch.isOn ? NSLocalizedString("Recording", comment: "Recording") : NSLocalizedString("rec_idle", comment: "Idle")
        default:
            break
        }
    }
}

extension HNLandscapeControlView {
    
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

}

extension HNLandscapeControlView: NibCreatable {}
