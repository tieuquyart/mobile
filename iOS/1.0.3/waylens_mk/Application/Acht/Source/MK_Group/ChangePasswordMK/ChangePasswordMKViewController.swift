//
//  ChangePasswordMKViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 12/26/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class ChangePasswordMKViewController: BaseViewController {
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var oldPwdView: UIView!
    @IBOutlet weak var repeatPwdView: UIView!
    @IBOutlet weak var newPwdView: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var viewMain: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
    }
    @IBAction func sendButtton(_ sender: Any) {
        if !isValidate() {
            return
        }
        onSave()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        hideNavigationBar(animated: animated)
        initHeader(text: "Đổi mật khẩu", leftButton: true)
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name.ReloadNotiList.reload, object: nil,userInfo: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showNavigationBar(animated: animated)
    }
    override func applyTheme() {
        oldPassword.placeholder = "Mật khẩu cũ"
        newPassword.placeholder = "Mật khẩu mới"
        repeatPassword.placeholder = "Nhập lại mật khẩu mới"
        oldPassword.isSecureTextEntry = true
        newPassword.isSecureTextEntry = true
        repeatPassword.isSecureTextEntry = true
        
        oldPwdView.layer.cornerRadius = 8
        oldPwdView.addShadow(offset: CGSize.init(width: 3, height: 4))
        repeatPwdView.layer.cornerRadius = 8
        repeatPwdView.addShadow(offset: CGSize.init(width: 3, height: 4))
        newPwdView.layer.cornerRadius = 8
        newPwdView.addShadow(offset: CGSize.init(width: 3, height: 4))
        
        sendButton.layer.cornerRadius = 8
        sendButton.layer.masksToBounds = true
        btnBack.layer.cornerRadius = 8
        btnBack.layer.borderWidth = 1
        btnBack.layer.borderColor = UIColor.gray.cgColor
        btnBack.layer.masksToBounds = true
        btnBack.isHidden = true
        viewMain.layer.cornerRadius = 8
        viewMain.layer.masksToBounds = true
        self.view.backgroundColor = UIColor.color(fromHex: ConstantMK.bg_main_color)
        
    }
    @IBAction func buttonBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func isValidate() -> Bool {
        if self.oldPassword.text == "" {
            self.toastMessage(message: "Mời nhập mật khẩu cũ")
            return false
        } else if self.newPassword.text == "" {
            self.toastMessage(message: "Mời nhập mật khẩu mới")
            return false
        } else if self.repeatPassword.text == "" {
            self.toastMessage(message: "Mời nhập lại mật khẩu mới")
            return false
        } else if (self.newPassword.text?.count ?? 0) < 8 {
            self.toastMessage(message: "Mật khẩu từ 8 đến 30 ký tự")
            return false
        } else if (self.newPassword.text?.count  ?? 0) > 30 {
            self.toastMessage(message: "Mật khẩu từ 8 đến 30 ký tự")
            return false
        } else if self.newPassword.text !=  self.repeatPassword.text {
            self.toastMessage(message: "Nhập khẩu nhập lại chưa trùng mật khẩu mới")
            return false
        }
        return true
    }
    func onSave() {
        view.endEditing(true)
        SessionService.shared.changePassword(newPassword: newPassword.text ?? "" , oldPassword: oldPassword.text ?? "", completion: { [weak self] (result) in
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
