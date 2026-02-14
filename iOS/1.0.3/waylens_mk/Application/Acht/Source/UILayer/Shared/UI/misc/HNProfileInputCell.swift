//
//  HNProfileInputCell.swift
//  Acht
//
//  Created by Chester Shen on 10/18/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class HNProfileInputCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    static let cellID = "HNProfileInputCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    private func setup() {
        let editIconView = UIImageView(image: #imageLiteral(resourceName: "icon_edit"))
        textField.rightView = editIconView
        textField.rightViewMode = .unlessEditing

        titleLabel.usingDynamicTextColor = true
        textField.usingDynamicTextColor = true
    }
    
}
