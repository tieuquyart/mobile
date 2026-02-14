//
//  TripDetailTimeLineTableViewCell.swift
//  Acht
//
//  Created by TranHoangThanh on 12/30/21.
//  Copyright © 2021 waylens. All rights reserved.
//

import UIKit

protocol EventVideoPlayDelegate {
    func playVideo(url: String, event: Event?)
    func playVideoErr(errMsg: String)
    func showLoading(_ show: Bool )
    
}

func setTextTranselate(text : String) -> String {
    return NSLocalizedString(text, comment: text)
}

class TripDetailTimeLineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeDrivingLabel: UILabel!
    @IBOutlet weak var infoDrivingLabel: UILabel!
    
    @IBOutlet weak var timeParkingLabel: UILabel!
    @IBOutlet weak var infoParkingLabel: UILabel!
    @IBOutlet weak var brandLb: UILabel!
    @IBOutlet weak var typeLb: UILabel!
    @IBOutlet weak var viewBrand: UIView!
    
    
    @IBOutlet weak var viewDriving: UIView!
    @IBOutlet weak var viewParking: UIView!
    @IBOutlet weak var viewBorder: UIView!
    
    var delegate : EventVideoPlayDelegate?
    
    
    @IBOutlet weak var viewEvent: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewDriving.layer.cornerRadius = 6.5
        viewParking.layer.cornerRadius = 6.5
        backgroundColor = .white
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
//        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//        self.layer.masksToBounds = true
        viewBorder.backgroundColor = .clear
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
        self.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.viewBrand.addDashedBorder()
        self.layer.masksToBounds = true
    }
    
    
    var eventModel : Event?
    
    var handlePlayVideo : ((Event?) -> Void)?
    
    let apiVideo : EventAPI = EventService()
    
    @IBAction func btnVideoClick(_ sender: Any) {
        self.handlePlayVideo?(eventModel)
    }
    
    @IBAction func btnPlayVideo(_ sender: Any) {
        self.handlePlayVideo?(eventModel)
    }
    
    
    func transDate(_ dateStr : String) -> String {
        let date = dateStr.toDate("yyy-MM-dd'T'HH:mm:ss")
        let str = date?.toFormat("HH:mm") ?? "Hiện tại"
        return str
    }
    
    func config(item : Event , trip : Trip) {
        viewEvent.isHidden = false
        timeDrivingLabel.text = "\(transDate(trip.drivingTime  ?? ""))"
        infoDrivingLabel.text = "\(item.driverName ?? "") Đã lái xe"
        
        timeParkingLabel.text = "\(transDate(trip.parkingTime ?? "Hiện tại"))"
        infoParkingLabel.text = "\(item.driverName ?? "") Đã đỗ xe"
        self.eventModel = item
    }
    
    func config(items : [Event] , trip : Trip, driver : Driver) {
        viewEvent.removeAllArrangedSubviews()
        viewEvent.isHidden = false
        
        for event in items {
            let view = EventView()
            view.setupData(item: event, delegate: self)
            viewEvent.addArrangedSubview(view)
        }
        timeDrivingLabel.text = "\(transDate(trip.drivingTime  ?? ""))"
        infoDrivingLabel.text = "\(trip.driverName ?? "") Đã lái xe"
        
        timeParkingLabel.text = "\(transDate(trip.parkingTime ?? "Hiện tại"))"
        infoParkingLabel.text = "\(trip.driverName ?? "") Đã đỗ xe"
        
        brandLb.text = driver.vehicle.brand
        typeLb.text = driver.vehicle.type
    }
    
    func getVideo(_ event : Event?) {
        self.delegate?.showLoading(true)
        apiVideo.video(id: event?.id ?? 0, completion: { [weak self] (result) in
            self?.delegate?.showLoading(false)
            switch result {
            case .success(let dict):
                if let data = dict["data"] as? String {
                    
                    
                    self?.delegate?.playVideo(url: data, event: event)
                    
                }
                break
            case .failure(let err):
                self?.delegate?.playVideoErr(errMsg: err?.localizedDescription ?? NSLocalizedString("Failed to apply settings, please check network connection.", comment: "Failed to apply settings, please check network connection."))
                break
            }
            
        })
    }
    
    
    func config(name : String , trip : Trip) {
        
        
        viewEvent.isHidden = true
        
        timeDrivingLabel.text = "\(transDate(trip.drivingTime  ?? ""))"
        infoDrivingLabel.text = "\(name) Đã lái xe"
        
        timeParkingLabel.text = "\(transDate(trip.parkingTime ?? "Hiện tại"))"
        infoParkingLabel.text = "\(name) Đã đỗ xe"
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
extension TripDetailTimeLineTableViewCell : EventViewDelegate {
    func onPlayVideo(event: Event?) {
        getVideo(event)
    }
}

extension UIView {
    func addDashedBorder() {
        let color = UIColor.gray.cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 12).cgPath
        
        self.layer.addSublayer(shapeLayer)
        
    }
}
