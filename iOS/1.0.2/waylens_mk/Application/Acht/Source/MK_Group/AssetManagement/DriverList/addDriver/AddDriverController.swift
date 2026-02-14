//
//  AddDriverController.swift
//  Acht
//
//  Created by TranHoangThanh on 2/10/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import DropDown

class RadioButtonController: NSObject {
    var buttonsArray: [UIButton]! {
        didSet {
            for b in buttonsArray {
                b.setImage(UIImage(named: "radio_empty"), for: .normal)
                b.setImage(UIImage(named: "radio_selected"), for: .selected)
            }
        }
    }
    var selectedButton: UIButton?
    var defaultButton: UIButton = UIButton() {
        didSet {
            buttonArrayUpdated(buttonSelected: self.defaultButton)
        }
    }
    
    func buttonArrayUpdated(buttonSelected: UIButton) {
        for b in buttonsArray {
            if b == buttonSelected {
                selectedButton = b
                b.isSelected = true
            } else {
                b.isSelected = false
            }
        }
    }
}


class AddDriverController: BaseViewController {
    
    
    var isAddDrive = true
    @IBOutlet weak var driverNameTf: UITextField!
    @IBOutlet weak var phoneNumberTf: UITextField!
    @IBOutlet weak var idNumberTf: UITextField!
    @IBOutlet weak var driverLicenseTf: UITextField!
    @IBOutlet weak var codeDriver: UITextField!
    @IBOutlet weak var viewOut: UIView!
    weak var delegate : AddVehicleControllerDelegate?
    var model : ParamDriver!
    
    var id : Int!
    
    @IBOutlet weak var txtBirthdayUser: UITextField!
    @IBOutlet weak var btnShowView: ButtonShowView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var okBtn: UIButton!
    let radioController: RadioButtonController = RadioButtonController()
//
    
    @IBOutlet weak var valid_until_tf: UITextField!
  //  var dates =  [Date]()
    
    @IBAction func btnMale(_ sender: UIButton) {
        self.isMale = true
        radioController.buttonArrayUpdated(buttonSelected: sender)
   //     self.genderTf.text =  "Nam"
    }
    
    @IBAction func btnFemale(_ sender: UIButton) {
        self.isMale = false
        radioController.buttonArrayUpdated(buttonSelected: sender)
//        self.genderTf.text = "Nữ"
    }
    var isMale = false
    
    
    let chooseDropDown = DropDown()
    
    var isCheckBirthday: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnShowView.delegate = self
        setupChooseDropDown()
        
        phoneNumberTf.keyboardType = .numberPad
        idNumberTf.keyboardType = .numberPad
        
        viewOut.layer.cornerRadius = 12
        viewOut.layer.masksToBounds = true
        
        cancelBtn.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
        okBtn.setTitle(NSLocalizedString("OK", comment: "OK"), for: .normal)
        okBtn.backgroundColor = UIColor.color(fromHex: ConstantMK.blueButton)
        ConstantMK.borderButton([cancelBtn,okBtn])
        ConstantMK.borderTF([driverNameTf,phoneNumberTf,idNumberTf,driverLicenseTf,valid_until_tf, codeDriver, txtBirthdayUser])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: animated)
        if !isAddDrive {
            self.title = "Sửa tài xế"
            disableTf([codeDriver])
            driverNameTf.text = model.name
            phoneNumberTf.text = model.phoneNo
            idNumberTf.text = model.idNumber
            driverLicenseTf.text = model.license
            btnShowView.infoLabel.text = model.licenseType
            txtBirthdayUser.text = model.getTimeBirthDateYear()
            print("licenseType: " + model.licenseType)
            
            valid_until_tf.text = model.getTimeDrivingYear()
            codeDriver.text = model.employeeId
            
        } else {
            self.title = "Thêm Tài Xế"
        }
        
        self.showNavigationBar(animated: animated)
    }
    
    
    func disableTf( _ values : [UITextField]) {
        values.forEach { yourTextField in
            yourTextField.isEnabled = false
            yourTextField.backgroundColor = .lightGray
        }
    }
    
    @IBAction func okBtn(_ sender: Any) {
        if formatText() {
            if isAddDrive {
                self.showAlert(title: "Thông báo", message: "Bạn chắc chắn muốn thêm user \(driverNameTf.text ?? "") vào đội xe", btnRight: "Đồng ý", action: {
                    self.add()
                })
            } else {
                self.showAlert(title: "Thông báo", message: "Bạn chắc chắn muốn sửa thông tin user \(driverNameTf.text ?? "")", btnRight: "Đồng ý", action: {
                    self.change()
                })
            }
        }
        
    }
    
    @IBAction func onBirthdayUser(_ sender: Any) {
        self.view.endEditing(true)
        isCheckBirthday = true
        addDatePicker()
    }
    
 //   var formattedDate: String? = ""
    
      var yearsTillNow: [String] {
        var years = [String]()
            for i in (1970..<2018).reversed() {
                years.append("\(i)")
            }
            return years
       }
    
    
    
    private lazy var datePicker : UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.autoresizingMask = .flexibleWidth
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        datePicker .backgroundColor = .white
        
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
        var date = UIDatePicker()
        if isCheckBirthday {
            self.txtBirthdayUser.text = date.date.toString(format: .custom("dd-MM-yyyy"))
        } else {
            self.valid_until_tf.text = date.date.toString(format: .custom("dd-MM-yyyy"))
        }
        
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
    }
    
    
    @objc private func dateChanged(picker : UIDatePicker) {
        if isCheckBirthday {
            self.txtBirthdayUser.text = picker.date.toString(format: .custom("dd-MM-yyyy"))
        } else {
            self.valid_until_tf.text = picker.date.toString(format: .custom("dd-MM-yyyy"))
        }
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
        
    }
    
    @IBAction func btnShowDate(_ sender: Any) {
        self.view.endEditing(true)
        isCheckBirthday = false
        addDatePicker()
    }

    func formatText() -> Bool {
        if let nameText = driverNameTf.text {
            if nameText.isEmpty  {
                self.showAlert(title: "Thông báo", message: "Hãy nhập thông tin Tên tài xế")
                return false
            }
        }
        
        if let birthdayUser = txtBirthdayUser.text {
            if birthdayUser.isEmpty  {
                self.showAlert(title: "Thông báo", message: "Hãy chọn ngày sinh tài xế")
                return false
            }
        }
        
        if let nameText = idNumberTf.text {
            if nameText.isEmpty  {
                self.showAlert(title: "Thông báo", message: "Hãy nhập thông tin Số CCCD")
                return false
            }
            
            if !(nameText.count == 12) {
                self.showAlert(title: "Thông báo", message: "Độ dài CCCD là 12 số")
                return false
            }
        }
        
        if let phoneText = phoneNumberTf.text {
            if phoneText.isEmpty  {
                self.showAlert(title: "Thông báo", message: "Hãy nhập thông tin Số điện thoại")
                return false
            }
            
            if !phoneText.validatePhone() {
                self.showAlert(title: "Thông báo", message: "Lỗi định dạng Số điện thoại")
                return false
            }
            
        }
        
        if let  driverLicenseText = driverLicenseTf.text {
            if driverLicenseText.isEmpty  {
                self.showAlert(title: "Thông báo", message: "Hãy nhập thông tin Giấy phép lái xe")
                return false
            }
            
            if !(driverLicenseText.count == 12) {
                self.showAlert(title: "Thông báo", message: "Độ dài số Giấy phép lái xe là 12 số")
                return false
            }
        }
        
        if let  rankText = btnShowView.infoLabel.text {
            if rankText.isEmpty  {
                self.showAlert(title: "Thông báo", message: "Hãy nhập thông tin Hạng")
                return false
            }
        }
        
        
        if let  timeText = valid_until_tf.text {
            if timeText.isEmpty  {
                self.showAlert(title: "Thông báo", message: "Hãy nhập thông tin thời hạn của Giấy phép lái xe")
                return false
            }
        }
        
        
        if let  codeText = codeDriver.text {
            if codeText.isEmpty  {
                self.showAlert(title: "Thông báo", message: "Hãy nhập thông tin Mã hiệu tài xế")
                return false
            }
            
            if  6 < codeText.count || codeText.count > 50 {
                self.showAlert(title: "Thông báo", message: "Mã hiệu tài xế không đúng định dạng")
                return false
            }
        }
        return true
    }
    
    
//    func validate(value: String) -> Bool {
//        let PHONE_REGEX = "(84|0[3|5|7|8|9])+([0-9]{8})"
//        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
//        let result = phoneTest.evaluate(with: value)
//        return result
//    }
    
    func setupChooseDropDown() {
        chooseDropDown.anchorView = btnShowView
        chooseDropDown.direction = .bottom
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseDropDown.bottomOffset = CGPoint(x: 40, y: btnShowView.viewBorder.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseDropDown.dataSource = [
            "B1",
            "B2",
            "C",
            "D",
            "E",
            "FB2",
            "FC",
            "FD",
            "FE"
        ]
        
        // Action triggered on selection
        chooseDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnShowView.infoLabel.text = item
            
        }
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: nil, message: "Success", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {  [weak self] action in
            self?.navigationController?.popViewController(animated: false)
            self?.delegate?.reloadData()
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func add() {
        model = ParamDriver(birthDate: txtBirthdayUser.text!, drivingYears: valid_until_tf.text! ,  employeeId: codeDriver.text!, gender: 0, idNumber: idNumberTf.text!, license: driverLicenseTf.text!, licenseType: btnShowView.infoLabel.text!, name: driverNameTf.text!, phoneNo: phoneNumberTf.text!)
        DriverService.shared.add_driver(_param: model, completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value, handler: {success, msg, code in
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
    
    func checkGender() -> Int {
        if isMale {
            return 1
        } else {
            return 0
        }
    }
    
    func change() {
        let model =  ParamDriver(birthDate: txtBirthdayUser.text!, drivingYears: valid_until_tf.text!  , employeeId: codeDriver.text!, gender: 0, idNumber: idNumberTf.text!, license: driverLicenseTf.text!, licenseType: btnShowView.infoLabel.text!, name: driverNameTf.text!, phoneNo: phoneNumberTf.text!)
        
        DriverService.shared.modify(id : id , _param: model, completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value, handler: {success, msg, code in
                    if success {
                        self?.showAlert()
                    }else{
                        self?.showErrorResponse(code: code)
                    }
                })
                
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }
            
        })
        
    }
    
}


extension AddDriverController : ButtonShowViewDelegate {
    func showView() {
        chooseDropDown.show()
    }
    
}

extension String {
    func applyPatternOnNumbers(pattern: String, replacementCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}
