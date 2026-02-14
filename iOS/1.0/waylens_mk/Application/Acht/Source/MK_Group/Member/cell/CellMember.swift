//
//  CellMember.swift
//  Acht
//
//  Created by TranHoangThanh on 2/17/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class CellMember: UITableViewCell {
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.arrowImageView.transform = CGAffineTransform(rotationAngle: (.pi/2) * (-1))
        //self.arrowImageView.isHidden = true
        // Initialization code
    }

    func showArrow() {
        self.arrowImageView.isHidden = false
    }
    
    func config(value: MemberInfo) {
        self.arrowImageView.isHidden = value.isShow
        self.titleLabel.text = value.title
        self.infoLabel.text = value.value
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
