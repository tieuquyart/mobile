//
//  TriggeringVehicleListCell.swift
//  Fleet
//
//  Created by forkon on 2020/5/19.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class TriggeringVehicleListCell: UITableViewCell {

    let plateNumberLabel: UILabel = {
        let plateNumberLabel = UILabel()
        return plateNumberLabel
    }()

    let driverLabel: UILabel = {
        let driverLabel = UILabel()
        return driverLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrame = layoutMarginsGuide.layoutFrame
        let dividedFrame = layoutFrame.divided(atDistance: bounds.width / 2, from: CGRectEdge.minXEdge)
        plateNumberLabel.frame = dividedFrame.slice
        driverLabel.frame = dividedFrame.remainder
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
        [plateNumberLabel, driverLabel].forEach({ (label) in
            label.textColor = UIColor.black
            label.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
        })
    }

    private func setup() {
        let margin = UIScreen.main.bounds.shorterEdge * 0.05
        layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)

        addSubview(plateNumberLabel)
        addSubview(driverLabel)

        applyTheme()
    }

}
