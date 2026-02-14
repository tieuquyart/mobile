//
//  CalibrationCameraOrientationContentView.swift
//  Fleet
//
//  Created by forkon on 2020/8/6.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit
import WaylensVideoSDK

class CalibrationCameraOrientationContentView: CalibrationPlayerContentView {
    private(set) var invertButton: UIButton = {
        let invertButton = UIButton(type: .custom)
        invertButton.setImage(#imageLiteral(resourceName: "invert"), for: .normal)
        invertButton.isEnabled = false
        return invertButton
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        maskImageView.isHidden = true
        bottomView.addSubview(invertButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrameDivider = RectDivider(rect: bottomView.bounds)

        invertButton.sizeToFit()
        let invertButtonAreaFrame = layoutFrameDivider.divide(atDistance: invertButton.frame.height, from: .minYEdge)
        invertButton.center = CGPoint(x: invertButtonAreaFrame.minX + invertButtonAreaFrame.width / 2, y: invertButtonAreaFrame.minY + invertButtonAreaFrame.height / 2)
    }

    override func player(_ player: WLVideoPlayer, stateDidChange state: WLVideoPlayerState) {
        super.player(player, stateDidChange: state)

        if state == .playing {
            invertButton.isEnabled = true
        }
        else {
            invertButton.isEnabled = false
        }
    }
}
