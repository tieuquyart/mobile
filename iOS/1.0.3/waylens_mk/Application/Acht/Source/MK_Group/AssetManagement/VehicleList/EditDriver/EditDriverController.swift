//
//  EditDriverController.swift
//  Acht
//
//  Created by TranHoangThanh on 2/18/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class EditDriverController: BaseViewController {
    
    weak var delegate : AddVehicleControllerDelegate?
    
    @IBOutlet weak var viewContainerTableView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var infoDriverLbl: UILabel!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    var listDriver = [DriverItemModel]()
    var driverId : Int = 0
    var model : VehicleItemModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.okButton.backgroundColor = UIColor.color(fromHex: ConstantMK.blueButton)
        self.okButton.setTitle(ConstantMK.okButton(), for: .normal)
        self.cancelBtn.setTitle(ConstantMK.cancelButton(), for: .normal)
        self.driverId = model.id ?? 0
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.viewContainer.layer.cornerRadius = 8
        self.viewContainer.layer.masksToBounds = true
        viewContainerTableView.layer.cornerRadius = 8
        viewContainerTableView.layer.borderWidth = 1
        viewContainerTableView.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
        viewContainerTableView.layer.masksToBounds = true
        viewInfo.layer.cornerRadius = 5
        viewInfo.layer.borderWidth = 0.5
        viewInfo.layer.borderColor = UIColor.darkGray.cgColor
        viewInfo.layer.masksToBounds = true
        infoDriverLbl.text = model.driverName != nil ? model.driverName : "Không có tài xế"
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.someAction (_:)))
        self.viewInfo.addGestureRecognizer(gesture)
        viewContainerTableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "EditCameraTableViewCell", bundle: nil), forCellReuseIdentifier: "EditCameraTableViewCell")
        getListDriver()
        ConstantMK.borderButton([okButton,cancelBtn])
        cancelBtn.backgroundColor = UIColor.white
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor.darkGray.cgColor
        cancelBtn.setTitleColor(UIColor.darkGray, for: .normal)
        cancelBtn.layer.masksToBounds = true
        
        viewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.closeAction(_:))))
    }
    
    @objc func someAction(_ sender:UITapGestureRecognizer) {
        viewContainerTableView.isHidden = false
    }
    
    @objc func closeAction(_ sender: UITapGestureRecognizer){
        viewContainerTableView.isHidden = true
    }
    
    func getListDriver() {
        DriverService.shared.list_driver( completion: { (result) in
         switch result {
            case .success(let value):
             ConstantMK.parseJson(dict: value, handler: {success, msg, code in
                 if success {
                     if let data = value["data"] as? [JSON] {
                         if let infoData = try? JSONSerialization.data(withJSONObject: data, options: []){
                             do {
                                 let items = try JSONDecoder().decode([DriverItemModel].self, from: infoData)
                                 self.listDriver = items
                                 self.tableView.reloadData()
                             } catch let err {
                                 print("err get VehicleProfile",err)
                             }
                         }
                     }
                 }else{
                     self.showErrorResponse(code: code)
                 }
             })
            case .failure(let err):
                 HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            }
        })
    }
    
    @IBAction func closeViewButton(_ sender: Any) {
        remove(asChildViewController: self)
    }
    @IBAction func cancelButton(_ sender: Any) {
        remove(asChildViewController: self)
    }
    
    @IBAction func okButton(_ sender: Any) {
        if let id = model.id {
            self.assignDriver(id: id, driverId: driverId)
           
        }
    
       // self.changeCamera(id: model.id, cameraId: cameraId)
    }
    
    func assignDriver(id : Int , driverId : Int) {
        VehicleService.shared.assignOneDriver(id: id, driverId: driverId, completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value, handler: {success, msg, code in
                    if success {
                        self?.back()
                    } else {
                        self?.showErrorResponse(code: code)
                    }
                })
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


extension EditDriverController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listDriver.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditCameraTableViewCell", for: indexPath) as! EditCameraTableViewCell
        let item = listDriver[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = listDriver[indexPath.row]
        infoDriverLbl.text = item.name
        self.driverId = item.id ?? 0
        self.viewContainerTableView.isHidden = true
    }
    
    }
    
    

