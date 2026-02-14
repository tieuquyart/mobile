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
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var fleetNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var realNameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var viewFleet: UIView!
    @IBOutlet weak var viewPhone: UIView!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewRealName: UIView!
    @IBOutlet weak var viewPass: UIView!
    @IBOutlet weak var viewUserName: UIView!
    
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
            viewRealName.isHidden = true
            viewFleet.isHidden = true
            viewPass.isHidden = true
            self.registerButton.setTitle(ConstantMK.language(str: "Send"), for: .normal)
        }
        applyTheme()
        
    }
    
    override func applyTheme() {
        registerButton.layer.cornerRadius = 12
        registerButton.layer.masksToBounds = true
        self.viewFleet.layer.cornerRadius = 8.0
        self.viewFleet.addShadow(offset: CGSize.init(width: 3, height: 4))
        self.viewUserName.layer.cornerRadius = 8.0
        self.viewUserName.addShadow(offset: CGSize.init(width: 3, height: 4))
        self.viewPass.layer.cornerRadius = 8.0
        self.viewPass.addShadow(offset: CGSize.init(width: 3, height: 4))
        self.viewRealName.layer.cornerRadius = 8.0
        self.viewRealName.addShadow(offset: CGSize.init(width: 3, height: 4))
        self.viewPhone.layer.cornerRadius = 8.0
        self.viewPhone.addShadow(offset: CGSize.init(width: 3, height: 4))
        self.viewEmail.layer.cornerRadius = 8.0
        self.viewEmail.addShadow(offset: CGSize.init(width: 3, height: 4))
        
     
   }

    func config() {

        guard let fleetName = fleetNameTextField.text , !fleetName.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input fleet name", comment: "Input fleet name"), to: nil)
            return
        }
        
        guard let userName = userNameTextField.text, !userName.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your userName", comment: "Input your userName"), to: nil)
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your password", comment: "Input your password"), to: nil)
            return
        }
        
        guard let realName = realNameTextField.text , !realName.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your realName address", comment: "Input your realName address"), to: nil)
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your email", comment: "Input your email"), to: nil)
            return
        }
        
        
        guard let mobile = mobileTextField.text, !mobile.isEmpty else {
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
                
                ConstantMK.parseJson(dict: dict) { success, msg, code in
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
                        self?.showErrorResponse(code: code)
                    }
                }
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Login Failed", comment: "Login Failed"), to: self?.navigationController)
                break
            }
        })
      
    }
    
    
    
    func createFleet() {

        guard let fleetName = fleetNameTextField.text , !fleetName.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your email address", comment: "Input your email address"), to: nil)
            return
        }

        
        guard let userName = userNameTextField.text, !userName.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your userName", comment: "Input your userName"), to: nil)
            return
        }
        
        
        guard let email = emailTextField.text, !email.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your email", comment: "Input your email"), to: nil)
            return
        }
        
        
        guard let mobile = mobileTextField.text, !mobile.isEmpty else {
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

        
        guard let userName = userNameTextField.text, !userName.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your userName", comment: "Input your userName"), to: nil)
            return
        }
        
        
        guard let email = emailTextField.text, !email.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your email", comment: "Input your email"), to: nil)
            return
        }
        
        
        guard let mobile = mobileTextField.text, !mobile.isEmpty else {
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
