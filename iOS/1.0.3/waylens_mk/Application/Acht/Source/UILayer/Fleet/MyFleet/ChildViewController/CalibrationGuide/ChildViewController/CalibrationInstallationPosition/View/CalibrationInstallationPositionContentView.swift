//
//  CalibrationInstallationPositionContentView.swift
//  Fleet
//
//  Created by forkon on 2020/8/6.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class CalibrationInstallationPositionContentView: UIView {

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "installation-dms")
        return imageView
    }()

    private var warningLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
        label.text = "ⓘ " + NSLocalizedString("The camera should not be higher than the driver's eyes.", comment: "The camera should not be higher than the driver's eyes.")
        return label
    }()

    private var installationGuideButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
        button.setTitle(NSLocalizedString("Installation Guide", comment: "Installation Guide"), for: .normal)
        button.isHidden = true
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(warningLabel)
        addSubview(installationGuideButton)
        applyTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrameDivider = RectDivider(rect: bounds)

        imageView.frame.size.height = layoutFrameDivider.remainder.width * 0.75
        imageView.frame = layoutFrameDivider.divide(atDistance: imageView.frame.height, from: .minYEdge)

        // padding
        layoutFrameDivider.divideOriginalRect(atPercent: 0.033, from: .minYEdge)

        installationGuideButton.sizeToFit()
        let installationGuideButtonAreaFrame = layoutFrameDivider.divide(atDistance: 40.0, from: .maxYEdge)
        installationGuideButton.center = CGPoint(x: installationGuideButtonAreaFrame.minX + installationGuideButtonAreaFrame.width / 2, y: installationGuideButtonAreaFrame.minY + installationGuideButtonAreaFrame.height / 2)

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

    func applyTheme() {
        installationGuideButton.setTitleColor(UIColor.black, for: .normal)
        installationGuideButton.addUnderline(with: UIColor.black)
        warningLabel.textColor = UIColor.black
    }

}
