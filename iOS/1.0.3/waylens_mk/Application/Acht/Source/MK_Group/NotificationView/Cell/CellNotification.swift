//
//  CellNotification.swift
//  Acht
//
//  Created by TranHoangThanh on 8/11/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class CellNotification: UITableViewCell {
    
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    
    @IBOutlet weak var plateNoLabel: UILabel!
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var viewContainerEvent: UIView!
    
    func setBorderViewAlert() {
        viewAlert.layer.cornerRadius = 5
        viewAlert.layer.masksToBounds = true
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
        setBorderViewAlert()
        setBorderView(view: self.viewContainer)
        setBorderViewText(view: self.viewContainerEvent)
        viewContainer.addShadow(offset: CGSize(width: 2, height: 3))
        viewContainerEvent.addShadow(offset: CGSize(width: 2, height: 3))
    }
    
    func setBorderViewText(view : UIView) {
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.backgroundColor = UIColor.color(fromHex: ConstantMK.redBGColor).cgColor
    }
    
    func configColorEventType(txt : String) {
        
        if txt == "DRIVING" {
            self.eventTypeLabel.textColor = UIColor.color(fromHex: ConstantMK.greenLabel)
            self.viewContainerEvent.backgroundColor =  UIColor.color(fromHex: ConstantMK.greenBG)
        } else if txt == "SIMCARDINFOCHANGED" || txt == "ACCOUNT_UNLOCK" || txt == "ACCOUNT_LOCK" || txt == "PARKING"  || txt == "NO_SEATBELT" || txt ==  "YAWN" {
            self.eventTypeLabel.textColor = UIColor.color(fromHex: ConstantMK.purpleText)
            self.viewContainerEvent.backgroundColor =  UIColor.color(fromHex: ConstantMK.purpleBG)
        } else if txt == "SUCCESS" {
            self.eventTypeLabel.textColor = UIColor.color(fromHex: ConstantMK.greenLabel)
            self.viewContainerEvent.backgroundColor =  UIColor.color(fromHex: ConstantMK.greenBG)
        } else {
            self.eventTypeLabel.textColor = UIColor.color(fromHex: ConstantMK.redTextColor)
            self.viewContainerEvent.backgroundColor =  UIColor.color(fromHex: ConstantMK.redBGColor)
        }
        
    }
    
    
    @IBOutlet weak var subscriptionNameLabel: UILabel!
    
    
    func setBorderView(view : UIView) {
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
    }
    
    func config(model : NotiItem) {
        
        if model.markRead {
            viewAlert.isHidden = true
        } else {
            viewAlert.isHidden = false
        }
        
        configColorEventType(txt : model.eventType?.toString() ?? "")
        alertLabel.text = model.alert?.localizeMk()
        
        eventTypeLabel.text = model.eventType?.description
        
        eventTimeLabel.text = model.eventTime?.localizeMk().replacingOccurrences(of: "T", with: " ")
        
        plateNoLabel.isHidden = false
        plateNoLabel.text =  showWithCategory(model: model)
        
        
    }
    
    func showWithCategory(model : NotiItem) -> String{
        if let category = model.category {
            if category == "ACCOUNT" {
                if model.eventType?.toString() == "SIMCARDINFOCHANGED" || model.eventType?.toString() == "CAMERATILTED_CHECKORIENTATION" {
                    return "Số seri: \(model.cameraSn?.localizeMk() ?? "")"
                }else{
                    return "Tài khoản: \(model.accountName?.localizeMk() ?? "")"
                }
            }else if category == "PAYMENT" {
                return "Sản phẩm: \(model.subscriptionName?.localizeMk() ?? "")"
            }else{
                return "Biển số: \(model.plateNo?.localizeMk() ?? "")"
            }
        }else{
            return ""
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
