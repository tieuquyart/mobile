//
//  VehicelTableViewCell.swift
//  Acht
//
//  Created by TranHoangThanh on 1/12/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class VehicelTableViewCell: UITableViewCell {

    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var licensePlateLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        idLabel.isHidden = true
    
        self.arrowImageView.transform = CGAffineTransform(rotationAngle: (.pi/2) * (-1))
    }
    
    
    
    func config(item : VehicleItemModel) {
        licensePlateLabel.text = item.plateNo
        cameraLabel.text = item.cameraSn
        imgView.image = UIImage(named: "vehicle")
       // idLabel.text = "\(item.id)"
    }
    
    func configCamera(item : CameraItemModel) {
        licensePlateLabel.text = item.sn
        cameraLabel.text = item.getStatus()
        imgView.image = UIImage(named: "camera_wifi")
        //idLabel.text = "\(item.id)"
    }
    
    func configDriver(item : DriverItemModel) {
        licensePlateLabel.text = item.name
        cameraLabel.text = item.phoneNo
        imgView.image = UIImage(named: "vehicle")
        //idLabel.text = "\(item.id)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
