//
//  PlayerPanelCreator.swift
//  Acht
//
//  Created by forkon on 2018/9/27.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class PlayerPanelCreator {

    class func createDefaultPlayerPanel() -> PlayerPanel {
        let cv = HNPlayerControlView(
            portraitControlView: HNPortraitControlView.createFromNib()!,
            landScapeControlView: HNLandscapeControlView.createFromNib()!
        )
        cv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let player = PlayerPanel(controlView: cv)
        cv.player = player
        cv.additionalAnimations = { [weak player] (isToHide) in
            if isToHide {
                player?.delegate?.showControls(show: false, duration: 0.4)
            } else {
                player?.delegate?.showControls(show: true, duration: 0.4)
            }
        }
        
        return player
    }
    
    class func createTranslucentPlayerPanel() -> PlayerPanel {
        let cv = HNPlayerControlView(
            portraitControlView: HNTranslucentControlView.createFromNib()!
        )
        cv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let player = PlayerPanel(controlView: cv)
        player.isPlayBarCoveredVideo = true
        cv.player = player
        cv.additionalAnimations = { [weak player] (isToHide) in
            if isToHide {
                player?.delegate?.showControls(show: false, duration: 0.4)
            } else {
                player?.delegate?.showControls(show: true, duration: 0.4)
            }
        }
        return player
    }
    
    class func createSelectRangePlayerPanel() -> PlayerPanel {
        let cv = HNPlayerControlView(
            portraitControlView: HNSelectRangeControlView.createFromNib()!
        )
        cv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let player = PlayerPanel(controlView: cv)
        cv.player = player
        cv.additionalAnimations = { [weak player] (isToHide) in
            if isToHide {
                player?.delegate?.showControls(show: false, duration: 0.4)
            } else {
                player?.delegate?.showControls(show: true, duration: 0.4)
            }
        }
        return player
    }
    
    class func createAlertDetailPlayerPanel() -> PlayerPanel {
        let portraitControlView = HNTranslucentControlView.createFromNib()!
        portraitControlView.fullScreenButton.isHidden = false
        
        let cv = HNPlayerControlView(
            portraitControlView: portraitControlView
        )
        cv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let player = PlayerPanel(controlView: cv)
        player.isPlayBarCoveredVideo = true
        cv.player = player
        cv.additionalAnimations = { [weak player] (isToHide) in
            if isToHide {
                player?.delegate?.showControls(show: false, duration: 0.4)
            } else {
                player?.delegate?.showControls(show: true, duration: 0.4)
            }
        }
        return player
    }

    class func createOverviewLivePlayerPanel() -> PlayerPanel {
        let portraitControlView = HNPortraitControlView.createFromNib()!
        portraitControlView.playBar.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let cv = HNPlayerControlView(
            portraitControlView: portraitControlView
        )
        cv.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let player = PlayerPanel(controlView: cv)
        player.isPlayBarCoveredVideo = true
        cv.player = player
        cv.additionalAnimations = { [weak player] (isToHide) in
            if isToHide {
                player?.delegate?.showControls(show: false, duration: 0.4)
            } else {
                player?.delegate?.showControls(show: true, duration: 0.4)
            }
        }

        return player
    }

    class func createEventDetailPlayerPanel() -> PlayerPanel {
        return createAlertDetailPlayerPanel()
    }
    
}
