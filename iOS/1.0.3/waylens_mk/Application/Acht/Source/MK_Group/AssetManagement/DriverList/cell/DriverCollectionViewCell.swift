//
//  DriverCollectionViewCell.swift
//  Acht
//
//  Created by TranHoangThanh on 12/20/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit


protocol DriverCollectionViewCellDelegate : AnyObject {
    func tapMoreCamera(view : UIView , item : CameraItemModel)
    func tapMoreVehicle(view : UIView , item :  VehicleItemModel)
    func tapMoreDriver(view : UIView , item : DriverItemModel)
    func tapAdd()
}

class DriverCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgAdd: UIImageView!
    @IBOutlet weak var plateNoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cameraSNLabel: UILabel!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewContainerAdd: UIView!
    weak var delegate : DriverCollectionViewCellDelegate?
    
    var item : DriverItemModel!
    
    func setBorderView(view : UIView) {
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
//        view.backgroundColor = UIColor.color(fromHex: ConstantMK.grayBG)
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setBorderView(view: self.viewContainer)
        setBorderView(view: self.viewContainerAdd)
        
        viewContainerAdd.addTapGesture {
            self.delegate?.tapAdd()
        }
        
        
    }

    
    func config(item : VehicleItemModel) {
        if item.isAdd {
            self.viewContainerAdd.isHidden = false
            self.viewContainer.isHidden = true
        } else {
            self.viewContainerAdd.isHidden = true
            self.viewContainer.isHidden = false
        }
        viewContainer.addTapGesture { [self] in
            self.delegate?.tapMoreVehicle(view: self.viewContainer, item: item)
        }
        
        //  self.item = item
        if item.driverName.isEmpty {
              nameLabel.text = "Thiếu tài xế"
              nameLabel.textColor = UIColor.color(fromHex: ConstantMK.redTextColor)
          } else {
              nameLabel.text = item.driverName
              nameLabel.textColor = UIColor.color(fromHex: ConstantMK.grayLabel)
          }
        
        //  self.item = item
          if item.cameraSn.isEmpty {
              cameraSNLabel.text = "Thiếu camera"
              cameraSNLabel.textColor = UIColor.color(fromHex: ConstantMK.redTextColor)
          } else {
              cameraSNLabel.text = item.cameraSn
              cameraSNLabel.textColor = UIColor.color(fromHex: ConstantMK.grayLabel)
          }
          
          
        
        plateNoLabel.text = item.plateNo
        plateNoLabel.font = UIFont(name: "BeVietnamPro-Medium", size: 16)!
//        nameLabel.text = item.driverName
//        cameraSNLabel.text = item.cameraSn
        imageProfile.image = UIImage(named: "icon_vehicle")
       // idLabel.text = "\(item.id)"
    }
    
    
    func configCamera(item : CameraItemModel) {
    
        if item.isAdd {
            self.viewContainerAdd.isHidden = false
            self.viewContainer.isHidden = true
        } else {
            self.viewContainerAdd.isHidden = true
            self.viewContainer.isHidden = false
        }
        viewContainer.addTapGesture { [self] in
            self.delegate?.tapMoreCamera(view: self.viewContainer, item: item)
        }
        plateNoLabel.text = item.sn
        plateNoLabel.font = UIFont(name: "BeVietnamPro-Medium", size: 16)!
        nameLabel.text = item.driverName
        nameLabel.isHidden = true
        cameraSNLabel.text = item.getStatus()
        cameraSNLabel.textColor = setColorTextWithStatus(status: item.status)
        imageProfile.image = UIImage(named: "icon_camera")
        //idLabel.text = "\(item.id)"
    }
    
    
    func setColorTextWithStatus(status: Int?) -> UIColor{
        if status == 2 {
            return UIColor.green
        } else if status == 0 {
            return UIColor.red
        }else {
            return UIColor.orange
        }
    }
    
    
    func configDriver(item : DriverItemModel) {
        if item.isAdd {
            self.viewContainerAdd.isHidden = false
            self.viewContainer.isHidden = true
        } else {
            self.viewContainerAdd.isHidden = true
            self.viewContainer.isHidden = false
        }
        viewContainer.addTapGesture { [self] in
            self.delegate?.tapMoreDriver(view: self.viewContainer, item: item)
        }
        plateNoLabel.isHidden = true
        cameraSNLabel.text = item.phoneNo
        nameLabel.text = item.name
        nameLabel.font = UIFont(name: "BeVietnamPro-Medium", size: 16)!
        nameLabel.numberOfLines = 0
        nameLabel.textColor = UIColor.color(fromHex: "#0B4296")
        imageProfile.image = UIImage(named: "icon_driver")
    }
}
