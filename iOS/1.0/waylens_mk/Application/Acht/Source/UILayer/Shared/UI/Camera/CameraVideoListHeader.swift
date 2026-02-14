//
//  CameraVideoListHeader.swift
//  Acht
//
//  Created by gliu on 6/19/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class CameraVideoListHeader: UITableViewHeaderFooterView {
    
    static func viewIdentifier() ->String {
        return "CameraVideoTableHeader"
    }
    
    @IBOutlet weak var dateLabel: UILabel!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
