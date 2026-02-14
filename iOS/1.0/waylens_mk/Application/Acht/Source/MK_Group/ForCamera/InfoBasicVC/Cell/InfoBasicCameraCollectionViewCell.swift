//
//  InfoBasicCameraCollectionViewCell.swift
//  Acht
//
//  Created by TranHoangThanh on 12/27/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class InfoBasicCameraCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    func config(item: InfoCameraMKModel) {
        keyLabel.text = item.key
        valueLabel.text = item.value
    }

}
