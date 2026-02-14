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
    
    
    
//    func  transDate(_ dateStr : String) -> String {
//        let dateFormatter = DateFormatter()
//          dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
//          dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
//        let abc = dateStr.split(separator: ".")[0]
//        let date = dateFormatter.date(from: String(abc))
//        let str = date?.toFormat("HH:mm") ?? ""
//        return str
//    }
    
    func update(with event: Event) {
        nameLabel.text = event.driverName ?? "NoName"
        plateLabel.text = event.plateNo ?? "NoPlate"
        dateLabel.text = event.startTime?.replacingOccurrences(of: "T", with: " ")
        imageEventView.image = FleetResource.Image.iconNoShadow29x29(for: EventType.from(string: event.eventType?.toString() ?? "") )
        
    }
    
    func update(with notiItem : NotiItem){
        nameLabel.text = notiItem.driverName ?? "NoName"
        plateLabel.text = notiItem.plateNo ?? "NoPlate"
//        dateLabel.text = transDate(notiItem.eventTime ?? "")
        dateLabel.text = notiItem.eventTime?.replacingOccurrences(of: "T", with: " ")
        imageEventView.image = FleetResource.Image.iconNoShadow29x29(for: EventType.from(string: notiItem.eventType?.toString() ?? "") )
    }
}
