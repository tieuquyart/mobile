//
//  TripCell.swift
//  Acht
//
//  Created by thanh on 09/01/2022.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import ExpandableCell

class TripCell: UITableViewCell {
    
    @IBOutlet weak var idTripLabel: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timeStartLabel: UILabel!
    @IBOutlet weak var timeEndLabel: UILabel!
    @IBOutlet weak var viewWarning: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var viewRight: UIView!
    @IBOutlet weak var viewLeft: UIView!
    @IBOutlet weak var viewInfoTrip : UIView!
    @IBOutlet weak var imgRight: UIImageView!
    var trip : Trip?
    @IBOutlet weak var imgDown: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imgDown.tintColor = .gray
        backgroundColor = .clear
        viewLeft.layer.cornerRadius = 8
        viewRight.layer.cornerRadius = 8
        viewAlert.layer.cornerRadius = 10
        viewWarning.layer.cornerRadius = 15
    }
    
    func setBorderWithExpanded(isExpanded : Bool){
        if isExpanded {
            imgDown.image = UIImage(named: "arrow-down")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.viewContainer.roundCornersCell([.topLeft, .topRight], radius: 12.0)
                self.viewContainer.layer.cornerRadius = 12.0
//                self.viewContainer.layer.borderColor = UIColor.color(fromHex: "#165FCE").cgColor
                self.viewContainer.layer.borderWidth = 1.0
            })
            
        } else {
            imgDown.image = UIImage(named: "arrow-right")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.viewContainer.roundCornersCell([.allCorners], radius: 12.0)
                self.viewContainer.layer.borderColor = UIColor.white.cgColor
                self.viewContainer.layer.borderWidth = 0
            })
        }
    }
    
    func transDate(_ dateStr : String) -> String {
        print("date String" , dateStr)
        let date = dateStr.toDate("yyyy-MM-dd'T'HH:mm:ss")
        let str = date?.toFormat("HH:mm") ?? "Hiện tại"
        return str
    }
    
    func config( _ item : Trip) {
        if item.eventCount ?? 0 == 0 {
            viewAlert.isHidden = true
        } else {
            viewAlert.isHidden = false
        }
        idTripLabel.text = "Trip #\(item.id ?? 0)"
        let hour = String(format:"%.2f", (item.hours ?? 0) * 60) + " phút"
        infoLabel.text = "\(hour) | \(((item.distance ?? 0)).measurementLength(unit: .kilometers).localeStringValue) km"
        infoLabel.textColor = UIColor.color(fromHex: ConstantMK.grayLabel)
        timeStartLabel.text = transDate(item.drivingTime ?? "null")
        let timeParking = transDate(item.parkingTime ?? "Hiện tại")
        
        if(timeParking == "Hiện tại"){
            viewRight.backgroundColor = UIColor.link
            imgRight.image = UIImage(named: "ic_blue")
        }else{
            viewRight.backgroundColor = UIColor.color(fromHex: "#51AE58")
            
        }
        timeEndLabel.text = timeParking
        countLabel.text = "\(item.eventCount ?? 0)"
    }
    
}
