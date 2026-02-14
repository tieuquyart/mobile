//
//  HNPortraitControlView.swift
//  Acht
//
//  Created by forkon on 2018/9/6.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class HNSelectRangeControlView: PassThroughView, HNPlayerControlProtocol, PlayerViewModeToggleable {
    
    static let playBarHeight: CGFloat = 36.0
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var viewModeButton: UIButton!
    
    weak var player: PlayerPanel?

    func updateUI() {
        guard let player = player else {
            return
        }
        
        switch player.playState {
        case .unloaded:
            playButton.setPlayAppearance()
        case .stopped:
            playButton.setPlayAppearance()
        case .playing:
            playButton.setPauseAppearance()
        case .paused:
            playButton.setPlayAppearance()
        case .buffering:
            playButton.setPauseAppearance()
        case .seeking:
            playButton.setPauseAppearance()
        case .completed, .error:
            playButton.setPlayAppearance()
        }
        
        switch player.viewMode {
        case .frontBack:
            viewModeButton.setViewModePanoramaAppearance()
        case .raw:
            viewModeButton.setViewModeShowDMSAppearance(show: player.showDMSInfo)
        case .panorama:
            viewModeButton.setViewModeFrontBackAppearance()
        }
    }
    
    func hideDMSFaceButton(hide: Bool) {
    }
    
    func showControlView() {
    }
    
    func hideControlView() {
    }

    func showResolutionButton(_ show: Bool, streams : Int) {
    }
    func showViewModeButton(_ show: Bool) {
        viewModeButton.isEnabled = show
    }
}

extension HNSelectRangeControlView {
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        player?.onPlay()
    }
    
    @IBAction func viewModeButtonTapped(_ sender: UIButton) {
        if player?.viewMode == .raw {
            viewModeButton.setViewModeShowDMSAppearance(show: !player!.showDMSInfo)
        }
        player?.onSwitchViewMode()
    }
}

extension HNSelectRangeControlView: NibCreatable {}
