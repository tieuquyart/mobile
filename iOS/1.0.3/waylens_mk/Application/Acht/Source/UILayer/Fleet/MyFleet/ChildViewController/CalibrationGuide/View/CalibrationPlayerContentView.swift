//
//  CalibrationPlayerContentView.swift
//  Fleet
//
//  Created by forkon on 2020/8/20.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit
import WaylensVideoSDK

class CalibrationPlayerContentView: UIView, Themed, WLVideoPlayerDelegate {
    private(set) var player: WLVideoPlayer!
    private(set) var maskImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "handle_top")
        return imageView
    }()
    private(set) var bottomView: UIView = {
        let view = UIView()
        return view
    }()

    private var playerContainingView: UIView = {
        let playerContainingView = UIView()
        playerContainingView.backgroundColor = UIColor.black
        playerContainingView.clipsToBounds = true
        return playerContainingView
    }()

    private var playerPanel: UIView = {
        let view = UIView()
        return view
    }()

    private var activityIndicator: WLActivityIndicator = {
        let activityIndicator = WLActivityIndicator(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        activityIndicator.isLight = true
        return activityIndicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        maskImageView.frame = playerContainingView.bounds
        addSubview(playerContainingView)
        addSubview(bottomView)
        playerContainingView.addSubview(playerPanel)
        playerContainingView.addSubview(maskImageView)
        playerContainingView.addSubview(activityIndicator)
        
        player = WLVideoPlayer(container: playerPanel)
        player.delegate = self
        player.dewarpParams.renderMode = .original

        activityIndicator.startAnimating()
        playerContainingView.bringSubviewToFront(activityIndicator)
    }
    
    func getImage() -> UIImageView? {
        let image = self.player?.getRawImageView()
        return image
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrameDivider = RectDivider(rect: bounds)

        playerContainingView.frame.size.height = layoutFrameDivider.remainder.width * 0.625
        playerContainingView.frame = layoutFrameDivider.divide(atDistance: playerContainingView.frame.height, from: .minYEdge)

        if let maskImage = maskImageView.image {
            maskImageView.frame = CGRect(x: 0.0, y: 0.0, width: playerContainingView.frame.width, height: playerContainingView.frame.width * (maskImage.size.height / maskImage.size.width))
        }
        else {
            maskImageView.frame = playerContainingView.bounds
        }

        playerPanel.frame = CGRect(x: 0.0, y: 0.0, width: playerContainingView.frame.width, height: playerContainingView.frame.width * (player.naturalSize.height / player.naturalSize.width))

        activityIndicator.center = CGPoint(x: playerContainingView.frame.width / 2, y: playerContainingView.frame.height / 2)

        // padding
        layoutFrameDivider.divideOriginalRect(atPercent: 0.045, from: .minYEdge)

        bottomView.frame = layoutFrameDivider.remainder
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    // MARK: - WLVideoPlayerDelegate

    func player(_ player: WLVideoPlayer, stateDidChange state: WLVideoPlayerState) {
        if state == .playing {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
        else {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            playerContainingView.bringSubviewToFront(activityIndicator)
        }
    }

    func player(_ player: WLVideoPlayer, aspectRatioDidChange aspectRatio: CGFloat) {
        setNeedsLayout()
    }

    func applyTheme() {

    }
}
