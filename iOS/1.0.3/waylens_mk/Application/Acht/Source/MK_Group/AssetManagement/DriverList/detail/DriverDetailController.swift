//
//  DriverDetailController.swift
//  Acht
//
//  Created by TranHoangThanh on 2/9/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

//{
//"id": 10,
//"employeeId": "7",
//"licenseType": "3",
//"license": "132456",
//"drivingYears": 6,
//"name": "TungNS1",
//"gender": 0,
//"idNumber": "113236",
//"birthDate": null,
//"phoneNo": "0855140137",
//"createTime": "2022-01-17T14:25:35",
//"updateTime": "2022-02-07T16:18:30"
//}



class DriverDetailController: BaseViewController {

    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var employeeIdLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var idNumberLabel: UILabel!
    @IBOutlet weak var driverLicenseLabel: UILabel!
    @IBOutlet weak var licenseTypeLabel: UILabel!
    @IBOutlet weak var drivingYearsLabel: UILabel!
    @IBOutlet weak var outView: UIView!
    
    var model : DriverItemModel!
    weak var delegate : AddVehicleControllerDelegate?
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var lbBirthdayUser: UILabel!
    
    func configView() {
        
        idLabel.text = "\(model.id ?? 0)"
        nameLabel.text = model.name
        employeeIdLabel.text = model.employeeId
        phoneLabel.text = model.phoneNo
        idNumberLabel.text = model.idNumber
        driverLicenseLabel.text = model.license
        licenseTypeLabel.text = model.licenseType
        drivingYearsLabel.text = model.getTimeDrivingYear()
        lbBirthdayUser.text = model.getTimeBirthDayUser()
        
//        outView.layer.cornerRadius = 8
//        outView.layer.borderWidth = 1
//        outView.layer.borderColor = UIColor.color(fromHex: "#EDEEF4").cgColor
//        outView.layer.masksToBounds = true
        outView.addShadow(offset: CGSize(width: 3, height: 4))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: animated)
        self.initHeader(text: "Thông tin tài xế", leftButton: true)
        self.showNavigationBar(animated: animated)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name.ReloadNotiList.reload, object: nil,userInfo: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    

    @IBAction func editBtn(_ sender: Any) {
        self.editVC(self.model)
    }
    
    @IBAction func deleteBtn(_ sender: Any) {
        self.remove(model)
    }
    
    func removeDriver(id : Int) {
        
        DriverService.shared.delete(id : id , completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                print(value.description)
              
                ConstantMK.parseJson(dict: value, handler: {success, msg,code  in
                    if success{
                        self?.reloadData()
                    }else{
                        self?.showErrorResponse(code: code)
                    }
                })
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }
        })
    }
    
    func editVC(_ model : DriverItemModel){
           let vc = AddDriverController()
           vc.isAddDrive = false
        vc.model = ParamDriver(birthDate: model.birthDate ?? "", drivingYears: model.drivingYears ?? "" , employeeId: model.employeeId ?? "" , gender: model.gender ?? 0 , idNumber: model.idNumber ?? "", license: model.license ?? "" , licenseType: model.licenseType ?? "" , name: model.name ?? "" , phoneNo: model.phoneNo ?? "")
           vc.id = model.id
           vc.delegate = self
          self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func remove(_ model : DriverItemModel) {
        
        self.alert(message: NSLocalizedString("", comment: "Are you sure to remove this Driver?"), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .destructive, handler: { [weak self] (action) in
                
                self?.removeDriver(id : model.id ?? 0)
                
            })
         }) { () -> UIAlertAction in
             return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Yes"), style: .cancel, handler: { (action) in
            })
        }
        
    }

}



extension DriverDetailController : AddVehicleControllerDelegate {
    func reloadData() {
        self.delegate?.reloadData()
        self.navigationController?.popViewController(animated: false)
    }
}
