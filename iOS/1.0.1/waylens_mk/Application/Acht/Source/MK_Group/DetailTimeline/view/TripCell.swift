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
    
    var trip : Trip?
    
    @IBOutlet weak var imgDown: UIImageView!
    func setBorderViewEx(view : UIView) {
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setBorderView(view : UIView) {
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
        view.layer.masksToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgDown.tintColor = .gray
        backgroundColor = .clear
        viewLeft.layer.cornerRadius = 8
        viewRight.layer.cornerRadius = 8
        viewAlert.layer.cornerRadius = 10
        viewWarning.layer.cornerRadius = 15
        self.setBorderView(view: self.viewContainer)
//        self.viewContainer.addDashedBorder()
    }
    
    func setBorderWithExpanded(isExpanded : Bool){
        imgSelected(isExpanded)
//        if isExpanded{
//            self.setBorderViewEx(view: (self.viewContainer)!)
//        }else{
//            self.setBorderView(view: self.viewContainer)
//        }
    }
    
    
    func imgSelected(_ value : Bool) {
        if value {
            imgDown.image = UIImage(named: "arrow-down")
        } else {
            imgDown.image = UIImage(named: "arrow-right")
        }
        
        imgDown.tintColor = .gray
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
        }else{
            viewRight.backgroundColor = UIColor.color(fromHex: "#51AE58")
        }
        timeEndLabel.text = timeParking
        countLabel.text = "\(item.eventCount ?? 0)"
    }
    
}
