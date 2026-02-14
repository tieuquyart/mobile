//
//  TimeInfoDriveHeader.swift
//  DemoCSV
//
//  Created by TranHoangThanh on 8/24/22.
//

import UIKit

class TimeInfoDriveHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var lblTitleTime:  UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func config(isDrivingTime: Bool){
        if isDrivingTime {
            lblTitleTime.text = "Thời gian lái xe (phút)"
        }else{
            lblTitleTime.text = "Thời gian dừng đỗ (phút)"
        }
    }

}
