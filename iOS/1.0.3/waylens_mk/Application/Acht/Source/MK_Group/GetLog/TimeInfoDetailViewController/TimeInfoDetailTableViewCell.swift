//
//  TimeInfoDetailTableViewCell.swift
//  DemoCSV
//
//  Created by TranHoangThanh on 8/25/22.
//

import UIKit

struct LogTimeDetail {
    let time : String
    let coordinate : String
    let speed : String
}


class TimeInfoDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblCoordinate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblStt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config( item : LogTimeDetail , index : Int) {
        lblStt.text = "\(index)"
        lblCoordinate.text = item.coordinate
        lblTime.text = item.time
        lblSpeed.text = item.speed
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
