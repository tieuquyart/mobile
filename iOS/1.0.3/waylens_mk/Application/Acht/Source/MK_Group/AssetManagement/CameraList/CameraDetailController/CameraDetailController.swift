//
//  CameraDetailController.swift
//  Acht
//
//  Created by TranHoangThanh on 1/24/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit



class CameraDetailController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var plateNoLable: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    
    var item : CameraItemModel!
    
    weak var delegate : AddVehicleControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.addShadow(offset: CGSize(width: 3, height: 4))
        
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: animated)
        
//        initHeader(text: NSLocalizedString("Chi tiết camera", comment: "Chi tiết camera"), leftButton: false)
        title = NSLocalizedString("Chi tiết camera", comment: "Chi tiết camera")
        
        self.showNavigationBar(animated: animated)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBack))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton

    }
    
    @objc func leftBack(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func configUI() {
        
        titleLabel.text = item.sn
        idLabel.text = "\(item.id ?? 0)"
        passwordLabel.text = item.password
        
        if(item.plateNo != nil && item.plateNo != ""){
            plateNoLable.isHidden = false
            plateNoLable.text = item.plateNo
        }else{
            plateNoLable.isHidden = true
        }
        
        plateNoLable.addTapGesture(action: {
            self.tapToPlateNo()
        })
        
        phoneLabel.text = item.phone
        statusLabel.text = item.getStatus()
    }
    
    func tapToPlateNo(){
        if let model = ConstantMK.getVehicleWithPlateNo(str: item?.plateNo) {
            let vc = VehicleDetailController()
            vc.delegate = self
            vc.model = model
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            self.showToast(message: "Không lấy được thông tin xe", seconds: 1)
        }
    }
    
    func back() {
        let alert = UIAlertController(title: nil, message: "Success", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.delegate?.reloadData()
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
}



extension CameraDetailController : AddVehicleControllerDelegate {
    func reloadData() {
        
        self.delegate?.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Put your code which should be executed with a delay here
            self.navigationController?.popViewController(animated: false)
        }
    }
}
