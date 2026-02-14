//
//  CalibrationAdjustCameraPositionContentView.swift
//  Fleet
//
//  Created by forkon on 2020/8/6.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class CalibrationAdjustCameraPositionContentView: CalibrationPlayerContentView {
    private var warningLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.text = NSLocalizedString("Look forward with an ordinary driving posture.\n\nAdjust the camera to make the driver image fit in the mask.", comment: "Look forward with an ordinary driving posture.\n\nAdjust the camera to make the driver image fit in the mask.")
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        bottomView.addSubview(warningLabel)

        applyTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrameDivider = RectDivider(rect: bottomView.bounds)

        let insetX: CGFloat = 10.0
        let preferredWarningLabelSize = warningLabel.sizeThatFits(layoutFrameDivider.remainder.insetBy(dx: insetX, dy: 0.0).size)
        if preferredWarningLabelSize.height > layoutFrameDivider.remainder.height {
            warningLabel.frame = layoutFrameDivider.remainder.insetBy(dx: insetX, dy: 0.0)
        }
        else {
            warningLabel.frame = layoutFrameDivider.divide(atDistance: preferredWarningLabelSize.height, from: .minYEdge).insetBy(dx: insetX, dy: 0.0)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    override func applyTheme() {
        super.applyTheme()

        warningLabel.textColor = UIColor.semanticColor(.label(.secondary))
    }
}
