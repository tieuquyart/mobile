//
//  RoleTableViewCell.swift
//  Acht
//
//  Created by TranHoangThanh on 2/17/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class RoleTableViewCell: UITableViewCell {

    @IBOutlet weak var imageCheck: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config(item : RoleItemModel) {
        titleLabel.text = item.roleName
        imageCheck.image = item.isCheck ? UIImage(named: "checkbox_selected") :  UIImage(named: "checkbox_empty")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
