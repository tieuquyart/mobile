//
//  HNCameraItemCell.swift
//  Acht
//
//  Created by Chester Shen on 11/3/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class HNCameraItemCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        applyTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

}

extension HNCameraItemCell: Themed {

    func applyTheme() {
        nameLabel.textColor = UIColor.semanticColor(.label(.secondary))
    }

}
