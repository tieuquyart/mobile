//
//  OverviewLiveHeaderView.swift
//  Fleet
//
//  Created by forkon on 2019/10/11.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class OverviewLiveHeaderView: UIView, NibCreatable {

//    @IBOutlet private weak var nameLabel: UILabel!
//    @IBOutlet private weak var imageView: UIImageView!
//    @IBOutlet private weak var plateLabel: UILabel!
//    @IBOutlet private weak var callButton: UIButton!

    var callHandler: (() -> ())? = nil
    @IBOutlet weak var viewTopStack: UIView!
    
    @IBOutlet weak var plateLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imgStatus: UIImageView!
    
    @IBOutlet weak var timeLabel: PaddingLabel!
    @IBOutlet weak var speedLabel: PaddingLabel!
    func setBorderView(view : UIView) {
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
    }
    
    func setFontButton(button : UIButton) {
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 8)
        button.setTitleColor(UIColor.color(fromHex: ConstantMK.grayLabel), for: .normal)
    }
    func setTextButtonLocalized(button : UIButton , text : String) {
        button.titleLabel?.text = NSLocalizedString(text, comment: text)
    }
    
    func setFontLabel(label : UILabel) {
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.color(fromHex: ConstantMK.grayLabel)
    }
    func setTextLabelLocalized(label : UILabel , text : String) {
        label.text = NSLocalizedString(text, comment: text)
    }
    

   
     func applyTheme() {
       
        self.backgroundColor = UIColor.semanticColor(SemanticColor.cardBackground)
        setFontLabel(label: labelName)
        setBorderView(view: self.viewTopStack)
        timeLabel.backGroundGrayMK()
        speedLabel.backGroundGrayMK()
        
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyTheme()
        
        
    }
    
//    let id: Int?
//    let clipId: String?
//    let cameraSn: String?
//    let driverId: Int?
//    let driverLicense: String?
//    let driverName: String?
//    let vehicleId: Int?
//    let plateNo: String?
//    let eventType: String?
//    let eventCategory: String?
//    let eventLevel: String?
//    let startTime: String?
//    let duration: TimeInterval?
//    let tripId: String?
//    let createTime: String?
//    let updateTime: String?
//    let gpsTime : String?
    
    func update(with event:  Event) {
        
        plateLabel.text = event.plateNo
//
//        mileageLabel.text = driver.statistics.mileage.localeStringValue
//
//        eventLabel.text = "\(driver.statistics.eventCount)"
//
//        labelName.text = driver.name
//
//        durationLabel.text = driver.statistics.duration.localeStringValue + " h"
//
//        speedLabel.text = "\(driver.statistics.speed) km/h"
//
//        if !driver.statistics.timeGPS.isEmpty {
//            timeLabel.text = driver.statistics.timeGPS.fixTimeLabel()
//            timeLabel.isHidden = false
//        } else {
//            timeLabel.isHidden = true
//        }
    }


    func update(with driver: Driver) {
        
        plateLabel.text = driver.vehicle.plateNumber
        
        mileageLabel.text = "\(driver.statistics.mileage.localeStringValue) km"
    
        eventLabel.text = "\(driver.statistics.eventCount)"
       
        labelName.text = driver.name
        
        if (driver.vehicle.state == .driving){
            imgStatus.image = UIImage(named: "driving_big_shadow")
        }else if (driver.vehicle.state == .parking){
            imgStatus.image = UIImage(named: "parking_big_shadow")
        }else{
            imgStatus.image = UIImage(named: "offline_big_shadow")
        }
        
        durationLabel.text = "\(driver.statistics.duration.localeStringValue) h"
        
        speedLabel.text = "\(driver.statistics.speed) km/h"
        
        if !driver.statistics.timeGPS.isEmpty {
            timeLabel.text = driver.statistics.timeGPS.fixTimeLabel()
            timeLabel.isHidden = false
        } else {
            timeLabel.isHidden = true
        }
    }

}

//MARK: - Action

extension OverviewLiveHeaderView {

    @IBAction func callButtonTapped(_ sender: Any) {
        callHandler?()
    }

}
