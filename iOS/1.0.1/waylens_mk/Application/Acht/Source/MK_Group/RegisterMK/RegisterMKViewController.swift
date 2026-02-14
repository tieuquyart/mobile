//
//  RegisterMKViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 11/25/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class RegisterMKViewController: BaseViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var userNameTextField: TextFieldMKCustom!
    @IBOutlet weak var emailTextField: TextFieldMKCustom!
    @IBOutlet weak var mobileTextField: TextFieldMKCustom!
    
    
    @IBOutlet weak var fleetNameTextField: TextFieldMKCustom!
    @IBOutlet weak var passwordTextField: TextFieldMKCustom!
    @IBOutlet weak var realNameTextField: TextFieldMKCustom!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    var isFleet : Bool = false
    var titleTxt = ""
    var isRememberPassword : Bool = false
    
    @IBOutlet weak var haveAccountLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.text = titleTxt
        if isRememberPassword {
            realNameTextField.isHidden = true
            passwordTextField.isHidden = true
            fleetNameTextField.isHidden = true
            realNameTextField.isHidden = true
            self.registerButton.setTitle(ConstantMK.language(str: "Send"), for: .normal)
        } else {
            if isFleet {
                realNameTextField.isHidden = true
                passwordTextField.isHidden = true
            }
        }
        
        
        
        applyTheme()
    }
    
    override func applyTheme() {
       
        self.titleLbl.textColor = UIColor.black
        self.titleLbl.font =  AppFont.regular.size(20)
         haveAccountLabel.font =  AppFont.regular.size(14)
        registerButton.titleLabel?.font = AppFont.regular.size(14)
      
        registerButton.layer.cornerRadius = 12
        registerButton.layer.masksToBounds = true
        fleetNameTextField.setTitle(str: "Tên Fleet")
        userNameTextField.setTitle(str: "Tên tài khoản")
        passwordTextField.setTitle(str: "Mật Khẩu")
        realNameTextField.setTitle(str: "Tên Thật")
        mobileTextField.setTitle(str: "Số điện thoại")
        emailTextField.setTitle(str: "Email")
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        
        loginButton.titleLabel?.font = AppFont.regular.size(14)
        
        self.view.backgroundColor = UIColor.color(fromHex: ConstantMK.bg_main_color)
     
   }

    func config() {

        guard let fleetName = fleetNameTextField.infoTextField.text , !fleetName.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input fleet name", comment: "Input fleet name"), to: nil)
            return
        }
        
        guard let userName = userNameTextField.infoTextField.text, !userName.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your userName", comment: "Input your userName"), to: nil)
            return
        }
        
        guard let password = userNameTextField.infoTextField.text, !password.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your password", comment: "Input your password"), to: nil)
            return
        }
        
        guard let realName = realNameTextField.infoTextField.text , !realName.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your realName address", comment: "Input your realName address"), to: nil)
            return
        }
        
        guard let email = emailTextField.infoTextField.text, !email.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your email", comment: "Input your email"), to: nil)
            return
        }
        
        
        guard let mobile = mobileTextField.infoTextField.text, !mobile.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your mobile ", comment: "Input your mobile "), to: nil)
            return
        }
        
        
        if !email.isValidEmail() {
            self.showAlert(title: "Thông báo", message:  "Lỗi định dạng Email")
            return
        }
        
        if !mobile.validatePhone() {
            self.showAlert(title: "Thông báo", message: "Lỗi định dạng Số điện thoại")
            return
        }
        
        HNMessage.show()

       let param = ParamRegisterMK(email: email, fleetId: "", fleetName: fleetName, id: "", mobile: mobile, password: password, realName: realName, userName: userName)

        FleetUserService.shared.register(_param: param , completion: { [weak self] (_result) in
            HNMessage.dismiss()
            
            switch _result {
            case .success(let dict):
                
                ConstantMK.parseJson(dict: dict) { success, msg in
                    if success{
                        let alert = UIAlertController(title: ConstantMK.language(str: "Thông báo") , message: ConstantMK.language(str: "Add success"), preferredStyle: UIAlertController.Style.alert)

                             // add the actions (buttons)
                              let ok = UIAlertAction(title: ConstantMK.language(str: "confirm"), style: .default, handler: { action in
                                 self?.navigationController?.popViewController(animated: true)
                               
                              })
                    
                             alert.addAction(ok)
                        
                      
                             // show the alert
                              self?.present(alert, animated: true, completion: nil)
                    }else{
                        if msg == "Invalid access token." {
                            self?.presentInvalidAccessToken()
                        } else{
                            let alert = UIAlertController(title: ConstantMK.language(str: "Thông báo") , message: msg.localizeMk(), preferredStyle: UIAlertController.Style.alert)
                            
                            let ok = UIAlertAction(title: "Cancel".localizeMk(), style: .cancel, handler: nil)
                            alert.addAction(ok)
                            
                            // show the alert
                            self?.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Login Failed", comment: "Login Failed"), to: self?.navigationController)
                break
            }
        })
      
    }
    
    
    
    func createFleet() {

        guard let fleetName = fleetNameTextField.infoTextField.text , !fleetName.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your email address", comment: "Input your email address"), to: nil)
            return
        }

        
        guard let userName = userNameTextField.infoTextField.text, !userName.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your userName", comment: "Input your userName"), to: nil)
            return
        }
        
        
        guard let email = emailTextField.infoTextField.text, !email.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your email", comment: "Input your email"), to: nil)
            return
        }
        
        
        guard let mobile = mobileTextField.infoTextField.text, !mobile.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your mobile ", comment: "Input your mobile "), to: nil)
            return
        }
        
        
        if !email.isValidEmail() {
            self.showAlert(title: "Thông báo", message: "Lỗi định dạng Email")
            return
        }
        
        if !mobile.validatePhone() {
            self.showAlert(title: "Thông báo", message: "Lỗi định dạng Số điện thoại")
            return
        }
        HNMessage.show()

       let param = ParamCreateFleetMK(contactEmail: email, contactMobile: mobile, contactName: userName, fleetId: "", id: "", name: fleetName)

        FleetUserService.shared.createFleet(_param: param , completion: { [weak self] (_result) in
            HNMessage.dismiss()
            switch _result {
               

            case .success(let dict):
                if let success = dict["success"] as? Bool {
                    
                    
                    
                                        if success {
                              
                                            let alert = UIAlertController(title: ConstantMK.language(str: "Alert") , message: ConstantMK.language(str: "Add success"), preferredStyle: UIAlertController.Style.alert)

                                                 // add the actions (buttons)
                                            let ok = UIAlertAction(title: ConstantMK.language(str: "confirm"), style: .default, handler: { action in
                                                     self?.backTwo()
                                                   
                                                 })
                                        
                                                 alert.addAction(ok)
                                            
                                          
                                                 // show the alert
                                                  self?.present(alert, animated: true, completion: nil)
                                            
                                            
                                        } else {
                                            if let mess = dict["message"] as? String {
                                                self?.showAlert(title:ConstantMK.language(str: "Alert"), message:ConstantMK.language(str: mess))
                                            }
                                           
                                        }
                    
                    
                } else {
                    HNMessage.showError(message: _result.error?.localizedDescription ?? NSLocalizedString("Login Failed", comment: "Login Failed"), to: self?.navigationController)
                }
                break
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Login Failed", comment: "Login Failed"), to: self?.navigationController)
                break
            }
        })
      
    }
    
    
    func resetPassword() {

        
        guard let userName = userNameTextField.infoTextField.text, !userName.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your userName", comment: "Input your userName"), to: nil)
            return
        }
        
        
        guard let email = emailTextField.infoTextField.text, !email.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your email", comment: "Input your email"), to: nil)
            return
        }
        
        
        guard let mobile = mobileTextField.infoTextField.text, !mobile.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your mobile ", comment: "Input your mobile "), to: nil)
            return
        }
        
        if !email.isValidEmail() {
            self.showAlert(title: "Thông báo", message:  "Lỗi định dạng Email")
            return
        }
        
        if !mobile.validatePhone() {
            self.showAlert(title: "Thông báo", message: "Lỗi định dạng Số điện thoại")
            return
        }
        
        HNMessage.show()

        let param =  ParamResetPasswordMK(email: email, mobile: mobile, userName: userName)
      
        FleetUserService.shared.resetPassword(_param: param , completion: { [weak self] (_result) in
            HNMessage.dismiss()
            switch _result {
               
            case .success(let dict):
                if let success = dict["success"] as? Bool {
                    
                    
                    
                    
                    
                    
                                        if success {

                                            
                                            // create the alert
                                            let alert = UIAlertController(title: ConstantMK.language(str: "Alert") , message: ConstantMK.language(str: "Send success"), preferredStyle: UIAlertController.Style.alert)

                                                 // add the actions (buttons)
                                            let ok = UIAlertAction(title: ConstantMK.language(str: "confirm"), style: .default, handler: { action in
                                                self?.navigationController?.popViewController(animated: true)
                                                   
                                                 })
                                        
                                                 alert.addAction(ok)
                                            
                                          
                                                 // show the alert
                                                  self?.present(alert, animated: true, completion: nil)
                                            
                                            
                                        } else {
                                            if let mess = dict["message"] as? String {
                                                self?.showAlert(title:ConstantMK.language(str: "Alert"), message:ConstantMK.language(str: mess))
                                            }
                                           
                                        }
                    
                    
                } else {
                    HNMessage.showError(message: _result.error?.localizedDescription ?? NSLocalizedString("Login Failed", comment: "Login Failed"), to: self?.navigationController)
                }
                break
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Login Failed", comment: "Login Failed"), to: self?.navigationController)
                break
            }
        })
      
    }
    @IBAction func registerButton(_ sender: Any) {
        if isRememberPassword {
            self.resetPassword()
        } else {
            if self.isFleet {
               // create fleet
                createFleet()
            }  else  {
                config()
            }
             
        }
       
    }
    
    
    
    @IBAction func loginButton(_ sender: Any) {
        if !isFleet {
            self.navigationController?.popViewController(animated: true)
        } else {
            backTwo()
        }
        
    }
    
}
