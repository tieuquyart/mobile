//
//  AddCameraViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 1/24/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import FSCalendar
class AddCameraViewController: BaseViewController {
    
    var isAddCamera = true
    var id : Int!
    @IBOutlet weak var cameraTypeTf: UITextField!
    @IBOutlet weak var passwdTf: UITextField!
    @IBOutlet weak var snTf: UITextField!
    @IBOutlet weak var daySetupTf: UITextField!
    @IBOutlet weak var phoneTf: UITextField!
    weak var delegate : AddVehicleControllerDelegate?
    
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var viewDate: UIView!
    
    @IBOutlet weak var viewOut : UIView!
   
    
    
    var model : ParamAddCamera!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneTf.keyboardType = .numberPad
        okBtn.setTitle(NSLocalizedString("OK", comment: "OK"), for: .normal)
        okBtn.layer.cornerRadius = 12
        okBtn.layer.masksToBounds = true
        cancelBtn.layer.cornerRadius = 12
        cancelBtn.layer.masksToBounds = true
        cancelBtn.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
        let rangeString =  Date().toString(format: .isoDate)
        self.daySetupTf.text = rangeString
       
        disableTf([cameraTypeTf])
        
        viewOut.layer.cornerRadius = 12
        viewOut.layer.masksToBounds = true
        
        ConstantMK.borderTF([snTf,phoneTf,daySetupTf,passwdTf,cameraTypeTf])
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: animated)
        if !isAddCamera {
            self.title = "Sửa thông tin camera"
            disableTf([snTf])
            snTf.text = model.sn
            phoneTf.text = model.phone
            daySetupTf.text = model.installationDate
            passwdTf.text = model.password
            
        }else{
            self.title = "Thêm Thiết Bị"
        }
        self.showNavigationBar(animated: animated)
    }
    
    func disableTf( _ values : [UITextField]) {
        values.forEach { yourTextField in
            yourTextField.isEnabled = false
            yourTextField.backgroundColor = .lightGray
        }
    }
    
    
    
    func formatText() -> Bool {
        if let snText = snTf.text {
         //   print("snText.count",snText.count)
            if snText.isEmpty || !snText.contains("6B") || !(snText.count == 8) {
                self.showAlert(title: "Thông báo", message: "Camera S/N nhập sai định dạng (6BXXXXXX)")
                return false
            }
        }
        
        if let phoneText = phoneTf.text {
            if phoneText.isEmpty  {
                self.showAlert(title: "Thông báo", message: "Hãy nhập thông tin Số điện thoại")
                return false
            }
            
            if !phoneText.validatePhone(){
                self.showAlert(title: "Thông báo", message: "Lỗi định dạng Số điện thoại")
                
                return false
            }
            
        }
        
        if let pwd = passwdTf.text {
            if pwd.isEmpty{
                self.showAlert(title: "Thông báo", message: "Vui lòng nhập mật khẩu")
                return false
            }
            
            if pwd.count != 8 {
                self.showAlert(title: "Thông báo", message: "Mật khẩu gồm 8 chữ số")
                return false
            }
        }
        
        
        return true
    }
    
//    func validate(value: String) -> Bool {
////        let PHONE_REGEX = "(84|0[3|5|7|8|9])+([0-9]{8})"
//        let PHONE_REGEX = "^[+]?[0-9]{10,13}$"
//        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
//        let result = phoneTest.evaluate(with: value)
//        return result
//    }


    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ok(_ sender: Any) {
        if formatText() {
            if isAddCamera {
                print("adđ")
                add()
            } else {
                print("change")
                change()
            }
        }
      
    }
    private lazy var datePicker : UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.autoresizingMask = .flexibleWidth
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        datePicker .backgroundColor = .white
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var toolBar : UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.onDoneClicked))]
        toolBar.sizeToFit()
        return toolBar
    }()
    
    
    
    private func addDatePicker() {
        self.view.addSubview(self.datePicker)
        self.view.addSubview(self.toolBar)
        
        NSLayoutConstraint.activate([
            self.datePicker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.datePicker.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.datePicker.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.datePicker.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        NSLayoutConstraint.activate([
            self.toolBar.bottomAnchor.constraint(equalTo: self.datePicker.topAnchor),
            self.toolBar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.toolBar.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.toolBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    @objc private func onDoneClicked() {
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
    }
    
    
    @objc private func dateChanged(picker : UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        let date = picker.date
        self.daySetupTf.text = date.toString(format: .isoDate)
        self.onDoneClicked()
        
    }
    
    
    @IBAction func showCalender(_ sender: UIButton) {
        addDatePicker()
    }
    
    func convertDateFormatter(date: String) -> String {

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"//this your string date format
   // dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
//    dateFormatter.locale = Locale(identifier: "your_loc_id")
    let convertedDate = dateFormatter.date(from: date)

    guard dateFormatter.date(from: date) != nil else {
    //    assert(false, "no date from string")
        return ""
    }
    dateFormatter.dateFormat = "HH:mm a"///this is what you want to convert format
   // dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
    let timeStamp = dateFormatter.string(from: convertedDate!)
    print(timeStamp)
    return timeStamp
    }

    
   
  

    func checkSN(value : String) -> Bool {
        if value.contains("6B") {
            return true
        }
        return false
    }
    
    
    
    func checkEmpty(values : [String]) -> Bool {

        for item in values {
            if item == "" {
                return false
            }
        }

        return true
    }
    
    
    
    func add() {
      
        
        
      
        let model = ParamAddCamera(sn: snTf.text!, password: passwdTf.text!, phone: phoneTf.text!, installationDate: daySetupTf.text!)
        
        CameraService.shared.add(_param: model, completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value, handler: {success, msg, code  in
                    if success {
                        self?.showAlert()
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
      
        model = ParamAddCamera(sn: snTf.text!, password: passwdTf.text!, phone: phoneTf.text!, installationDate: daySetupTf.text!)
        
        CameraService.shared.edit(id : id , _param: model, completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value, handler: {success, msg, code in
                    if success {
                        self?.showAlert()
                    }else {
                        self?.showErrorResponse(code: code)
                    }
                })
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }
            
        })
    }

  
    func showAlert() {
        let alert = UIAlertController(title: nil, message: "Success", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {  [weak self] action in
            self?.delegate?.reloadData()
            self?.navigationController?.popViewController(animated: false)
        }))
        present(alert, animated: true, completion: nil)
    }

}



