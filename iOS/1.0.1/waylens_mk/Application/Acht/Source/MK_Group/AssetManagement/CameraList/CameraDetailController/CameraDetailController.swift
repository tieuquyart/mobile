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
    @IBOutlet weak var ssidLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
//    @IBOutlet weak var FCCIDLabel: UILabel!
    @IBOutlet weak var plateNoLable: UILabel!
    @IBOutlet weak var fccIdLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var vehicleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var outView: UIView!
    
    
    var item : CameraItemModel!
    
    weak var delegate : AddVehicleControllerDelegate?
    
    @IBOutlet weak var waitingRegistration: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        editButton.backgroundColor = UIColor.color(fromHex: ConstantMK.blueButton)
        deleteButton.setTitle(NSLocalizedString("Delete", comment: "Delete"), for: .normal)
        deleteButton.layer.cornerRadius = 12
        deleteButton.layer.masksToBounds = true
        editButton.layer.cornerRadius = 12
        editButton.layer.masksToBounds = true
        waitingRegistration.layer.cornerRadius = 12
        waitingRegistration.layer.masksToBounds = true
        
        outView.layer.cornerRadius = 12
        outView.layer.masksToBounds = true
        
        if item.status != 0 {
            self.waitingRegistration.isHidden = true
            self.editButton.isHidden = true
        } else {
            self.waitingRegistration.isHidden = false
            self.editButton.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: animated)
        
        self.title  = "Chi tiết Camera"
        
        self.showNavigationBar(animated: animated)
    }
    
    @IBAction func waitingRegistration(_ sender: Any) {
        self.waitingCamera(item)
    }
    
    
    @IBAction func vehicleDetail(_ sender: Any) {
        getVehicle(id: item.id ?? 0)
        
    }
    
    
    @IBAction func editButton(_ sender: Any) {
        let vc = AddCameraViewController()
        vc.isAddCamera = false
        vc.model = ParamAddCamera(sn: item.sn ?? "", password: item.password ?? "" , phone: item.phone ?? "", installationDate: item.installationDate ?? "")
        vc.id = item.id
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
        
        
    
    func waitingRegistration(id : Int) {

        CameraService.shared.register(id : id , completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                //print(value.description)
                if let success = value["success"] as? Bool {
                    if success {
                        self?.showAlert(title: "Thông báo", message: "Thành công")
                        self?.waitingRegistration.isEnabled = false
                        self?.waitingRegistration.backgroundColor = .gray
                    } else {
                        if let message = value["message"] as? String {
                            self?.showErrorResponse(msg: message)
                        }
                    }

                }
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }

        })
    }
    
    @IBAction func btnBackLoad(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getVehicle(id : Int) {
        VehicleService.shared.getVehicleByCamera(id: id, completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                print(value.description)
                ConstantMK.parseJson(dict: value, handler: {success, msg in
                    if success {
                        if let data = value["data"] as? JSON {
                            if let infoData = try? JSONSerialization.data(withJSONObject: data, options: []){
                                do {
                                    let item = try JSONDecoder().decode(VehicleItemModel.self, from: infoData)
                                    let vc = VehicleDetailController()
                                    vc.model = item
                                    vc.isEdit = false
                                    self!.navigationController?.pushViewController(vc, animated: true)
                                } catch let err {
                                    print("err get VehicleProfile",err)
                                }
                            }
                               
                        }else{
                            
                        }
                    }else{
                        self?.showErrorResponse(msg: msg)
                    }
                })
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }
        })
    }

    
    
    func configUI() {
        titleLabel.text = item.sn
        idLabel.text = "\(item.id ?? 0)"
        ssidLabel.text = item.ssid
        passwordLabel.text = item.password
//        snLabel.text = item.sn
        if(item.plateNo != nil && item.plateNo != ""){
            plateNoLable.isHidden = false
            plateNoLable.text = item.plateNo
        }else{
            plateNoLable.isHidden = true
        }
        
        plateNoLable.addTapGesture(action: {
            self.tapToPlateNo()
        })
        
        fccIdLabel.text = item.fccid
        phoneLabel.text = item.phone
        vehicleLabel.text = item.plateNo ?? ""
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
    
    
    @IBAction func remove(_ sender: Any) {
        removeItem(item)
    }
    
    
    func removeCamera(id : Int) {
        
        CameraService.shared.delete(id : id , completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                //print(value.description)
                ConstantMK.parseJson(dict: value, handler: {success, msg in
                    if success {
                        self?.back()
                    } else {
                        self?.showErrorResponse(msg: msg)
                    }
                })
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }
            
        })
    }
    func removeItem(_ model : CameraItemModel) {
        self.alert(message: NSLocalizedString("Are you sure to remove this Camera?", comment: "Are you sure to remove this Camera?"), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .destructive, handler: { [weak self] (action) in
                self?.removeCamera(id: model.id ?? 0)
            })
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Yes"), style: .cancel, handler: { (action) in
            })
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
    
   
    
    func waitingCamera(_ model : CameraItemModel) {
        self.alert(message: NSLocalizedString("Xác nhận kích hoạt camera?", comment: "Xác nhận kích hoạt camera?"), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .destructive, handler: { [weak self] (action) in
                self?.waitingRegistration(id: model.id ?? 0)
            })
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Yes"), style: .cancel, handler: { (action) in
            })
        }
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
