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
    @IBOutlet weak var stackViewAll: UIStackView!
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
        viewDriving.layer.cornerRadius = 6.5
        viewParking.layer.cornerRadius = 6.5
        viewBorder.backgroundColor = .clear
        self.viewBrand.addDashedBorder()
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
        let date = dateStr.toDate("yyyy-MM-dd'T'HH:mm:ss")
        let str = date?.toFormat("HH:mm") ?? "Hiện tại"
        return str
    }
    func config(item : Event , trip : Trip) {
        viewEvent.isHidden = false
        timeDrivingLabel.text = "\(transDate(trip.drivingTime  ?? ""))"
        infoDrivingLabel.text = "\(item.driverName ?? "") Đã lái xe"
        let timeParking = transDate(trip.parkingTime ?? "Hiện tại")
        timeParkingLabel.text = timeParking
        if(timeParking == "Hiện tại"){
            infoParkingLabel.text = "\(item.driverName ?? "") Đang lái xe"
            viewParking.backgroundColor = UIColor.link
        }else{
            infoParkingLabel.text = "\(item.driverName ?? "") Đã đỗ xe"
            viewParking.backgroundColor = UIColor.color(fromHex: "#51AE58")
        }
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
        let timeParking = transDate(trip.parkingTime ?? "Hiện tại")
        timeParkingLabel.text = timeParking
        if(timeParking == "Hiện tại"){
            infoParkingLabel.text = "\(trip.driverName ?? "") Đang lái xe"
            viewParking.backgroundColor = UIColor.link
        }else{
            infoParkingLabel.text = "\(trip.driverName ?? "") Đã đỗ xe"
            viewParking.backgroundColor = UIColor.color(fromHex: "#51AE58")
        }
        brandLb.text = driver.vehicle.brand
        typeLb.text = driver.vehicle.type
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.roundCornersCell([.bottomLeft, .bottomRight], radius: 12.0)
        })
    }
    
    func getVideo(_ event : Event?) {
        self.delegate?.showLoading(true)
        apiVideo.video(id: event?.id ?? 0, completion: { [weak self] (result) in
            self?.delegate?.showLoading(false)
            switch result {
            case .success(let dict):
                if let data = dict["data"] as? Dictionary<String, Any> {
                    if let url = data["mp4Url"] as? String {
                        self?.delegate?.playVideo(url: url, event: event)
                    }
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
        timeDrivingLabel.text = "\(transDate(trip.drivingTime  ?? "NoTime"))"
        infoDrivingLabel.text = "\(name) Đã lái xe"
        timeParkingLabel.text = "\(transDate(trip.parkingTime ?? "Hiện tại"))"
        infoParkingLabel.text = "\(name) Đã đỗ xe"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
extension UIView {
    func roundCornersCell(_ corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
    }

}
