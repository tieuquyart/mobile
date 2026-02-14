//
//  EditCameraTableViewCell.swift
//  Acht
//
//  Created by TranHoangThanh on 1/21/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class EditCameraTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func config(item : CameraModel) {
        nameLabel.text  = "S/N \(item.sn)"
    }
    
    func config(item : DriverItemModel) {
        nameLabel.text  = "\(item.name ?? "null")"
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
