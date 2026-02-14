//
//  ChangePasswordMKViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 12/26/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class ChangePasswordMKViewController: BaseViewController {

    @IBOutlet weak var oldPassword: TextFieldMKCustom!
    @IBOutlet weak var repeatPassword: TextFieldMKCustom!
    @IBOutlet weak var newPassword: TextFieldMKCustom!
    
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var viewMain: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        applyTheme()
    }

    @IBAction func sendButtton(_ sender: Any) {
        onSave()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

       hideNavigationBar(animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        showNavigationBar(animated: animated)
    }
    
    override func applyTheme() {
        oldPassword.setTitle(str: "Mật khẩu cũ")
        newPassword.setTitle(str: "Mật khẩu mới")
        repeatPassword.setTitle(str: "Lăp lại mật khẩu mới")
        sendButton.titleLabel?.font = AppFont.regular.size(14)
        btnBack.titleLabel?.font = AppFont.regular.size(14)
        sendButton.layer.cornerRadius = 12
        sendButton.layer.masksToBounds = true
        btnBack.layer.cornerRadius = 12
        btnBack.layer.masksToBounds = true
        viewMain.layer.cornerRadius = 12
        viewMain.layer.masksToBounds = true
        self.view.backgroundColor = UIColor.color(fromHex: ConstantMK.bg_main_color)
   }

    @IBAction func buttonBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
     func onSave() {
        view.endEditing(true)
        guard let currentPwd = oldPassword.infoTextField.text, currentPwd != "" else {
            HNMessage.showError(message: NSLocalizedString("Input current password.", comment: "Input current password."))
            newPassword.infoTextField.becomeFirstResponder()
            return
        }
         guard let newPwd = newPassword.infoTextField.text, newPwd != "", repeatPassword.infoTextField.text == newPwd else {
            
             HNMessage.showError(message: WLCopy.confirmPassowrdTip)
             newPassword.infoTextField.text = nil
             repeatPassword.infoTextField.text = nil
            newPassword.becomeFirstResponder()
            return
        }
         SessionService.shared.changePassword(newPassword: currentPwd , oldPassword: currentPwd, completion: { [weak self] (result) in
             if result.isSuccess {
                 
                 if let value = result.value {
                     if let success = value["success"] as? Bool {
                         if !success {
                             HNMessage.showError(message: value["message"] as? String ?? "Fail to reset password")
                         } else {
                             HNMessage.showSuccess(message: NSLocalizedString("reset_password_successfully", comment: "Reset password successfully.\nLogin with new password"), to: nil)
                             AccountControlManager.shared.keyChainMgr.onLogOut()
                             AppViewControllerManager.gotoLogin()
                         }
                     }
                 }
                 
             } else {
                 if result.error?.asAPIError == .wrongVerificationToken {
                     HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Incorrect verification code", comment: "Incorrect verification code"), to: nil)
                     self?.navigationController?.popViewController(animated: true)
                 } else {
                     HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Fail to reset password", comment: "Fail to reset password"), to: nil)
                 }
             }
         })
    }

    
}
