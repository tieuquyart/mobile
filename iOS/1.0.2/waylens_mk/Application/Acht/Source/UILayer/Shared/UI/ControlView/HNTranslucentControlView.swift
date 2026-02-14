//
//  HNTranslucentControlView.swift
//  Acht
//
//  Created by forkon on 2018/9/27.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class HNTranslucentControlView: PassThroughView, HNPlayerControlProtocol, PlayerViewModeToggleable {
    fileprivate var refreshProgressTimer: Timer?

    weak var player: PlayerPanel?
    
    @IBOutlet weak var playBar: PassThroughView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressSlider: TLProgressSlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var viewModeButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    deinit {
        killRefreshProgressTimer()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    func updateUI() {
        guard let player = player else {
            return
        }
        
        let playState = player.playState
        
        switch playState {
        case .unloaded:
            playButton.setPlayAppearance()
        case .stopped:
            playButton.setPlayAppearance()
        case .playing:
            playButton.setPauseAppearance()
            startRefreshProgressTimer()
        case .paused:
            playButton.setPlayAppearance()
        case .buffering:
            playButton.setPauseAppearance()
        case .seeking:
            playButton.setPlayAppearance()
        case .completed, .error:
            playButton.setPlayAppearance()
        }
        
        if playState == .unloaded || playState == .stopped {
            progressSlider.value = 0
            refreshTimeLabel()
        }
        
        if playState == .unloaded || playState == .stopped || playState == .paused || playState == .completed {
            killRefreshProgressTimer()
        }
        
        switch player.viewMode {
        case .frontBack:
            viewModeButton.setViewModePanoramaAppearance()
        case .raw:
            viewModeButton.setViewModeShowDMSAppearance(show: player.showDMSInfo)
        case .panorama:
            viewModeButton.setViewModeFrontBackAppearance()
        }
        
        if player.fullScreen {
            fullScreenButton.setExitFullScreenAppearance()
        } else {
            fullScreenButton.setFullScreenAppearance()
        }
    }
    
    func hideDMSFaceButton(hide: Bool) {
    }
    
    func showControlView() {
        playBar.alpha = 1.0
    }
    
    func hideControlView() {
        playBar.alpha = 0.0
    }

    func showResolutionButton(_ show: Bool, streams : Int) {
    }
    func showViewModeButton(_ show: Bool) {
        viewModeButton.isEnabled = show
    }
}

extension HNTranslucentControlView {
    
    fileprivate func setup() {
        progressSlider.delegate = self
    }
    
    @objc fileprivate func refreshProgressAndTimeLabel() {
        guard let player = player, !progressSlider.isDragging else {
            return
        }
        
        let progress = Float((player.startOffset + player.videoPlayer!.currentPlaybackTime) / player.duration)
        progressSlider.value = progress

        refreshTimeLabel()
    }
    
    @objc fileprivate func refreshTimeLabel() {
        guard let player = player else {
            return
        }
        
        let progress = progressSlider.value
        let currentTime = TimeInterval(progress * Float(player.duration))
    //print("player.duration,\(NSString(time: player.duration)!)"
       currentTimeLabel.text = "\(NSString(time: currentTime)!) / \(NSString(time: player.duration / 1000)!)"
    }
    
    fileprivate func startRefreshProgressTimer() {
        if refreshProgressTimer == nil {
            refreshProgressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshProgressAndTimeLabel), userInfo: nil, repeats: true)
        }
    }
    
     fileprivate func killRefreshProgressTimer() {
        guard refreshProgressTimer != nil else { return }
        refreshProgressTimer?.invalidate()
        refreshProgressTimer = nil
    }
    
}

extension HNTranslucentControlView {
    
    @IBAction func progressSliderValueChanged(_ sender: TLProgressSlider) {
        refreshTimeLabel()
        player?.delegate?.onSeeking()
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        player?.onPlay()
    }
    
    @IBAction func viewModeButtonTapped(_ sender: Any) {
        if player?.viewMode == .raw {
            viewModeButton.setViewModeShowDMSAppearance(show: !player!.showDMSInfo)
        }
        player?.onSwitchViewMode()
    }
    
    @IBAction func fullScreenButtonTapped(_ sender: Any) {
        player?.onFullScreen()
    }
    
}

extension HNTranslucentControlView: TLProgressSliderDelegate {
    
    func slideBegan() {
        player?.playState = .seeking
        player?.delegate?.onSeekingBegan()
    }
    
    func slideEnded() {
        guard let player = player else {
            return
        }
        player.videoPlayer?.seek(to: TimeInterval(progressSlider.value * Float(player.duration)) - player.startOffset)
        player.delegate?.onSeekingEnded()
    }
    
}

extension HNTranslucentControlView: NibCreatable {}
