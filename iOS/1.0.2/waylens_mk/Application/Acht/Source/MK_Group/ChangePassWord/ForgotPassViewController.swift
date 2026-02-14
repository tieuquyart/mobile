//
//  ForgotPassViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 1/6/22.
//  Copyright © 2022 waylens. All rights reserved.
//


import UIKit

class ForgotPassViewController: AccountPageViewController, UITextFieldDelegate {
    
    @IBOutlet weak var oldinput: HNInputField!
    @IBOutlet weak var mainButton: HNMainButton!
    @IBOutlet weak var input: HNInputField!
    @IBOutlet weak var reInput: HNInputField!
    @IBOutlet weak var tipLabel: UILabel!
    
    var emailText: String?
    var token: String?
    
    static func createViewController() -> ForgotPassViewController {
        let vc = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassViewController")
        return vc as! ForgotPassViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInputField(input, validate: true)
        setupInputField(reInput, validate: true)
        tipLabel.text = nil
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        oldinput.becomeFirstResponder()
    }
    
    @IBAction func onMain(_ sender: Any) {
        view.endEditing(true)
        //        guard let password = input.text, password.isValidPassword(), password == reInput.text, let token = token, let email = emailText else { return }
        
        guard let password = input.text , let oldPassword = oldinput.text else {return}
        SessionService.shared.changePassword(newPassword: password, oldPassword: oldPassword, completion: { [weak self] (result) in
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
                    self?.container?.pop()
                } else {
                    HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Fail to reset password", comment: "Fail to reset password"), to: nil)
                }
            }
        })
        
        
        //        WaylensClientS.shared.resetPassword(email: email, token: token, password: password) { [weak self] (result) in
        //            if result.isSuccess {
        //                HNMessage.showSuccess(message: NSLocalizedString("reset_password_successfully", comment: "Reset password successfully.\nLogin with new password"), to: nil)
        //                #if FLEET
        //                AccountControlManager.shared.keyChainMgr.onLogOut()
        //                AppViewControllerManager.gotoLogin()
        //                #else
        //                AccountControlManager.shared.keyChainMgr.onLogOut()
        //                let vc = LoginViewController.createViewController()
        //                vc.emailText = email
        //                self?.container?.setRoot(vc)
        //                #endif
        //            } else {
        //                if result.error?.asAPIError == .wrongVerificationToken {
        //                    HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Incorrect verification code", comment: "Incorrect verification code"), to: nil)
        //                    self?.container?.pop()
        //                } else {
        //                    HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Fail to reset password", comment: "Fail to reset password"), to: nil)
        //                }
        //            }
        //        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        container?.pop()
    }
    
    // MARK: - UITextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //        if let oldString = textField.text as NSString? {
        //            let newString = oldString.replacingCharacters(in: range, with: string) as String
        //
        ////            if textField
        ////
        ////
        ////            if textField == input {
        ////                input.isValid = newString.isValidPassword()
        ////                tipLabel.text = input.isValid ? "" : WLCopy.passwordTip
        ////            } else {
        ////                reInput.isValid = newString == input.text
        ////                tipLabel.text = reInput.isValid ? "" : WLCopy.confirmPassowrdTip
        ////            }
        //        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onMain(mainButton as Any)
        return true
    }
    
}
