//
//  HNTableViewCell.swift
//  Acht
//
//  Created by Chester Shen on 7/23/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class HNTableViewCell: UITableViewCell {
    static let cellID = "HNTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        textLabel?.usingDynamicTextColor = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
