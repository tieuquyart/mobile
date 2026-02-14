//
//  TripFleetDetailCollectionViewCell.swift
//  Acht
//
//  Created by TranHoangThanh on 2/23/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class TripFleetDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewContainer.layer.cornerRadius = 5
        viewContainer.layer.masksToBounds = true
        viewContainer.layer.borderColor = UIColor.lightGray.cgColor
        viewContainer.layer.borderWidth = 1
        
        
    }
    
    
    func transDate(_ dateStr : String) -> String {
        let date = dateStr.toDate("yyyy-MM-dd'T'HH:mm:ss")
        let str = date?.toFormat("HH:mm") ?? "now"
        return str
    }
    
    func configTrip(trip : Trip) {
        
        viewContainer.layer.borderColor = trip.isClicked ? UIColor.color(fromHex: ConstantMK.blueButton).cgColor : UIColor.lightGray.cgColor
      //  self.viewContainer.backgroundColor = trip.isClicked ? .yellow : .white
        totalTimeLabel.text = "Trip#\(trip.id ?? 0)"
        toTimeLabel.text = "To: \(transDate(trip.parkingTime ?? ""))"
        fromTimeLabel.text = "From: \(transDate(trip.drivingTime ?? ""))"
    }

}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
