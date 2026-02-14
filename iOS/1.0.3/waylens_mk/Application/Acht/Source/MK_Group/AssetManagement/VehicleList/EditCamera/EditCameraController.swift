//
//  EditCameraController.swift
//  Acht
//
//  Created by TranHoangThanh on 1/18/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class EditCameraController: UIViewController {
    weak var delegate : AddVehicleControllerDelegate?
    @IBOutlet weak var viewContainerTableView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var infoCameraLbl: UILabel!
    @IBOutlet weak var viewInfo: UIView!
    
    var model : VehicleItemModel!
    var list_camera : [CameraModel] = []
    
    var cameraId : Int = 0
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraId = model.id ?? 0
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.okButton.backgroundColor = UIColor.color(fromHex: ConstantMK.blueButton)
        self.okButton.setTitle(ConstantMK.okButton(), for: .normal)
        self.cancelBtn.setTitle(ConstantMK.cancelButton(), for: .normal)
        self.viewContainer.layer.cornerRadius = 5
        self.viewContainer.layer.masksToBounds = true
        viewContainerTableView.layer.cornerRadius = 8
        viewContainerTableView.layer.borderWidth = 1
        viewContainerTableView.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
        viewContainerTableView.layer.masksToBounds = true
        viewInfo.layer.cornerRadius = 5
        viewInfo.layer.borderWidth = 0.5
        viewInfo.layer.borderColor = UIColor.darkGray.cgColor
        viewInfo.layer.masksToBounds = true
        infoCameraLbl.text = model.cameraSn != nil ? model.cameraSn : "Không có camera"
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.someAction (_:)))
        self.viewInfo.addGestureRecognizer(gesture)
        viewContainerTableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "EditCameraTableViewCell", bundle: nil), forCellReuseIdentifier: "EditCameraTableViewCell")
        getListCamera()
        ConstantMK.borderButton([okButton,cancelBtn])
        cancelBtn.backgroundColor = UIColor.white
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor.darkGray.cgColor
        cancelBtn.setTitleColor(UIColor.darkGray, for: .normal)
        cancelBtn.layer.masksToBounds = true
        // Do any additional setup after loading the view.
        
        viewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.closeAction(_:))))
    }
    
    
    
    func getListCamera() {
        CameraService.shared.camera_list(completion: { [weak self] (result) in
            
            switch result {
            case .success(let value):
                if let vehicleInfos = value["data"] as? [JSON] {
                    if let infoData = try? JSONSerialization.data(withJSONObject: vehicleInfos, options: []){
                        do {
                            let items = try JSONDecoder().decode([CameraModel].self, from: infoData)
                            self?.list_camera = items
                            self?.tableView.reloadData()
                        } catch let err {
                            print("err get CameraModel",err)
                        }
                    }
                }
            case .failure(let err):
                print("\(err?.localizedDescription ?? "")")
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }
            
        })
    }
    
    @objc func someAction(_ sender:UITapGestureRecognizer) {
        viewContainerTableView.isHidden = false
    }
    
    @objc func closeAction(_ sender:UITapGestureRecognizer){
        viewContainerTableView.isHidden = true
    }
    
    @IBAction func closeViewButton(_ sender: Any) {
        remove(asChildViewController: self)
    }
    @IBAction func cancelButton(_ sender: Any) {
        remove(asChildViewController: self)
    }
    
    @IBAction func okButton(_ sender: Any) {
        if let id = model.id {
            self.changeCamera(id: id, cameraId: cameraId)
        }
        
    }
    
    func changeCamera(id : Int , cameraId : Int) {
        VehicleService.shared.changeCamera(id: id, cameraId: cameraId, completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                if let success = value["success"] as? Bool {
                    if success {
                        self?.back()
                    } else {
                        if let message = value["message"] as? String {
                            self?.alert(title: "Alert", message: message)
                        }
                    }
                    
                }
            case .failure(let err):
                print("\(err?.localizedDescription ?? "")")
            }
        })
    }
    
    func back() {
        let alert = UIAlertController(title: nil, message: "Success", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.delegate?.reloadData()
            self.remove(asChildViewController: self)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func remove(asChildViewController childController: UIViewController) -> Void {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
    
    
}

extension EditCameraController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_camera.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditCameraTableViewCell", for: indexPath) as! EditCameraTableViewCell
        let item = list_camera[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = list_camera[indexPath.row]
        infoCameraLbl.text = item.sn
        self.cameraId = item.id
        self.viewContainerTableView.isHidden = true
    }
    
}



