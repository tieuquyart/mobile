//
//  AddVehicleController.swift
//  Acht
//
//  Created by TranHoangThanh on 1/13/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

protocol AddVehicleControllerDelegate : AnyObject {
    func reloadData()
}
class AddVehicleController: BaseViewController {
    
    var isAddVehicle : Bool!
    var model : ParamVehicle!
    var id : Int!
    weak var delegate : AddVehicleControllerDelegate?
    @IBOutlet weak var licensePlateNuberTf: UITextField!
    @IBOutlet weak var vehicleBrandTf: UITextField!
    @IBOutlet weak var internalNumberTf: UITextField!
    @IBOutlet weak var vehicleTypeTf: UITextField!
    @IBOutlet weak var viewOut : UIView!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var viewPlateNo: UIView!
    @IBOutlet weak var viewBrand: UIView!
    @IBOutlet weak var viewInternalNumber: UIView!
    @IBOutlet weak var viewVehicleType: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        okBtn.backgroundColor = UIColor.color(fromHex: ConstantMK.blueButton)
        cancelBtn.backgroundColor = UIColor.white
        okBtn.setTitle(NSLocalizedString("OK", comment: "OK"), for: .normal)
        cancelBtn.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
        ConstantMK.borderButton([okBtn,cancelBtn])
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor.darkGray.cgColor
        cancelBtn.setTitleColor(UIColor.darkGray, for: .normal)
        cancelBtn.layer.masksToBounds = true
        self.borderTF([viewPlateNo,viewBrand,viewInternalNumber,viewVehicleType])
    }
    
    func borderTF( _ items : [UIView]) {
        items.forEach { v in
            v.layer.cornerRadius = 8
            v.layer.masksToBounds = true
            v.addShadow(offset: CGSize(width: 3, height: 4))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: animated)
        if !isAddVehicle {
            
            disableTf([licensePlateNuberTf,internalNumberTf])
            
            disableV([viewPlateNo,viewInternalNumber])
            
            licensePlateNuberTf.text = model.plateNo
            vehicleBrandTf.text = model.brand
            internalNumberTf.text = model.vehicleNo
            vehicleTypeTf.text = model.type
            
            initHeader(text: "Sửa thông tin xe", leftButton: false)
            
        }else{
            initHeader(text: "Thêm xe mới", leftButton: false)
        }
        
        self.showNavigationBar(animated: animated)
    
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func regexLicensePlate(value: String) -> Bool {
        let LicensePlate_REGEX = "([0-9]{2}[A-Z|a-z][0-9]{4,5})"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", LicensePlate_REGEX)
        let result = phoneTest.evaluate(with: value)
        return result
    }
    
    
    func formatText() -> Bool {
        if let licensePlateText = licensePlateNuberTf.text {
            if licensePlateText.isEmpty  {
                self.alert(title: "Thông báo", message: "Hãy nhập thông tin Biển số xe")
                return false
            }
            
            if !regexLicensePlate(value: licensePlateText) {
                self.alert(title: "Thông báo", message: "Biển số xe không đúng format")
                return false
            }
            
        }
        
        if let vehicleBrandText = vehicleBrandTf.text {
            if vehicleBrandText.isEmpty  {
                self.alert(title: "Thông báo", message: "Hãy nhập thông tin Hãng xe")
                return false
            }
        }
        
        if let internalNumberText = internalNumberTf.text {
            if internalNumberText.isEmpty  {
                self.alert(title: "Thông báo", message: "Hãy nhập thông tin Mã hiệu xe")
                return false
            }
        }
        
        if let vehicleTypeText = vehicleTypeTf.text {
            if vehicleTypeText.isEmpty  {
                self.alert(title: "Thông báo", message: "Hãy nhập thông tin Kiểu xe")
                return false
            }
        }
        
        return true
        
    }
    
    func disableV( _ values : [UIView]) {
        values.forEach { v in
            v.backgroundColor = .lightGray
        }
    }
    
    func disableTf(_ values : [UITextField]){
        values.forEach { tf in
            tf.isEnabled = false
            tf.backgroundColor = .lightGray
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func okButton(_ sender: Any) {
        if formatText() {
            if isAddVehicle {
                add()
            } else {
                change()
            }
        }
        
    }
    
    func add() {
        
        model = ParamVehicle(brand: vehicleBrandTf.text!, plateNo: licensePlateNuberTf.text!, type: vehicleTypeTf.text!, vehicleNo: internalNumberTf.text!)
        
        VehicleService.shared.add_vehicle(_param: model, completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value, handler: { success, msg, code in
                    if success {
                        self?.alert()
                    } else {
                        self?.showErrorResponse(code: code)
                    }
                })
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }
            
        })
    }
    
    
    func change() {
        
        model = ParamVehicle(brand: vehicleBrandTf.text!, plateNo: licensePlateNuberTf.text!, type: vehicleTypeTf.text!, vehicleNo: internalNumberTf.text!)
        
        VehicleService.shared.modify_vehicle(id : id , _param: model, completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value, handler: {success, msg, code in
                    if success{
                        self?.alert()
                    }else{
                        self?.showErrorResponse(code: code)
                    }
                })
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }
            
        })
    }
    
    
    func alert() {
        let alert = UIAlertController(title: nil, message: "Success", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {  [weak self] action in
            self?.navigationController?.popViewController(animated: false)
            self?.delegate?.reloadData()
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
}
