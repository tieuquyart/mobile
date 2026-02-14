//
//  TriggeringVehicleSelectorCell.swift
//  Fleet
//
//  Created by forkon on 2020/5/19.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class TriggeringVehicleSelectorCell: UITableViewCell, Themed {

    let plateNumberLabel: UILabel = {
        let plateNumberLabel = UILabel()
        return plateNumberLabel
    }()

    let driverLabel: UILabel = {
        let driverLabel = UILabel()
        return driverLabel
    }()

    let selectionIndicatorView: UIImageView = {
        let selectionIndicatorView = UIImageView()
        selectionIndicatorView.contentMode = .left
        return selectionIndicatorView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            selectionIndicatorView.image = #imageLiteral(resourceName: "checkbox_selected")
        }
        else {
            selectionIndicatorView.image = #imageLiteral(resourceName: "checkbox_empty")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrame = layoutMarginsGuide.layoutFrame
        let dividedFrame = layoutFrame.divided(atDistance: 34.0, from: CGRectEdge.minXEdge)
        selectionIndicatorView.frame = dividedFrame.slice
        plateNumberLabel.frame = dividedFrame.remainder.divided(atDistance: dividedFrame.remainder.size.width / 2, from: CGRectEdge.minXEdge).slice
        driverLabel.frame = dividedFrame.remainder.divided(atDistance: dividedFrame.remainder.size.width / 2, from: CGRectEdge.minXEdge).remainder
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
        selectionIndicatorView.tintColor = UIColor.semanticColor(.tint(.primary))

        [plateNumberLabel, driverLabel].forEach({ (label) in
            label.textColor = UIColor.semanticColor(.label(.secondary))
            label.font = UIFont.systemFont(ofSize: 14.0)
        })
    }

    private func setup() {
        let margin = UIScreen.main.bounds.shorterEdge * 0.05
        layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)

        addSubview(selectionIndicatorView)
        addSubview(plateNumberLabel)
        addSubview(driverLabel)

        applyTheme()
    }

}

