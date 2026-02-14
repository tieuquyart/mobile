//
//  EventDetailHeaderView.swift
//  Fleet
//
//  Created by forkon on 2019/10/11.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class EventDetailHeaderView: UIView, NibCreatable {
    
    @IBOutlet private weak var imageEventView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var plateLabel: UILabel!
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnExport: UIButton!
    
    @IBOutlet weak var viewAll: UIView!
    // var event:Event!
    var cloruseExportClip : (()->())?
    //    func update(with event: Event) {
    //        nameLabel.text = event.driver
    //        plateLabel.text = event.plateNumber
    //        dateLabel.text = event.startTime.dateManager.fleetDate.toStringUsingInNotificationList()
    //        imageEventView.image = FleetResource.Image.iconNoShadow29x29(for: event.type)
    //
    //
    //        self.setBorderView(view: viewContainer)
    //        configBtnDownload()
    //
    //    }
    
    
    func configBtnDownload() {
        let smsImage  = UIImage(named: "arrow-down-mk")!
        btnExport.addRightIcon(image: smsImage)
    }
    
    
    func setBorderBgView(view : UIView) {
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.backgroundColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
    }
    
    
    
    func setBorderView(view : UIView) {
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
    }
    
    @IBAction func btnExport(_ sender: Any) {
        self.cloruseExportClip?()
        
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setBorderBgView(view: viewContainer)
        self.setBorderView(view: viewAll)
        btnExport.layer.cornerRadius = 12
        btnExport.layer.masksToBounds = true
    }
    
    
    
    func  transDate(_ dateStr : String) -> String {
        let date = dateStr.toDate("yyy-MM-dd'T'HH:mm:ss")
        let str = date?.toFormat("HH:mm") ?? ""
        return str
    }
    
    func update(with event: Event) {
        nameLabel.text = event.driverName ?? "456"
        plateLabel.text = event.plateNo ?? "123"
        dateLabel.text = transDate(event.startTime ?? "")
        imageEventView.image = FleetResource.Image.iconNoShadow29x29(for: EventType.from(string: event.eventType?.toString() ?? "") )
        
    }
    
    func update(with notiItem : NotiItem){
        nameLabel.text = notiItem.driverName ?? "456"
        plateLabel.text = notiItem.plateNo ?? "123"
        dateLabel.text = transDate(notiItem.eventTime ?? "")
        imageEventView.image = FleetResource.Image.iconNoShadow29x29(for: EventType.from(string: notiItem.eventType?.toString() ?? "") )
    }
}
