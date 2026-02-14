//
//  HNCSRadioChoiceCell.swift
//  Acht
//
//  Created by forkon on 2019/8/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class HNCSRadioChoiceCell: UITableViewCell {
    @IBOutlet private weak var selectionIndicatorView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        selectionStyle = .none
        selectionIndicatorView.backgroundColor = UIColor.clear
        selectionIndicatorView.layer.cornerRadius = selectionIndicatorView.frame.height / 2
        selectionIndicatorView.layer.borderColor = UIColor.color(fromHex: ConstantMK.blueButton).cgColor
        selectionIndicatorView.layer.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            selectionIndicatorView.layer.borderWidth = 6.0
        } else {
            selectionIndicatorView.layer.borderWidth = 1.0
        }
    }

}

//extension HNCSRadioChoiceCell: NibCreatable {}
