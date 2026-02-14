//
//  CameraTimeLineHeaderView.swift
//  Acht
//
//  Created by Chester Shen on 7/17/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class CameraTimeLineHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }
    
    func setTitle(_ title:String?) {
        titleLabel.text = title
    }
}
