//
//  TimeInfoDriveTableViewCell.swift
//  DemoCSV
//
//  Created by TranHoangThanh on 8/24/22.
//

import UIKit

struct LogTimeDrivingBean {
    let driverName : String
    let timeStart : String
    let timeACCoff : String
    let timeDrivingCurrent : Double
}


class TimeInfoDriveTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDrive: UILabel!
    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var lblTimeStop: UILabel!
    @IBOutlet weak var lblTimeStart:  UILabel!
    @IBOutlet weak var viewDriverName:  UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config( item : LogTimeDrivingBean , index : Int) {
        lblIndex.text = "\(index)"
        print("item.timeStart",item.timeStart)
        viewDriverName.isHidden = false
        lblTotalTime.text = String(format: "%.2f",item.timeDrivingCurrent)
        lblTimeStop.text = item.timeACCoff
        lblTimeStart.text = item.timeStart
        lblDrive.text = item.driverName
    }
    
    func configTimeStop( item: LogTimeDrivingBean, index: Int){
        lblIndex.text = "\(index)"
        viewDriverName.isHidden = true
        lblTotalTime.text = String(format: "%.2f",item.timeDrivingCurrent)
        lblTimeStop.text = item.timeACCoff
        lblTimeStart.text = item.timeStart
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
