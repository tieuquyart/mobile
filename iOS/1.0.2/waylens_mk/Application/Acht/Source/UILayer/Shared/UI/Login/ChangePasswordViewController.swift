//
//  ChangePasswordViewController.swift
//  Acht
//
//  Created by Chester Shen on 10/31/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class ChangePasswordViewController: BaseTableViewController {
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var current: HNInputField!
    @IBOutlet weak var newPassword: HNInputField!
    @IBOutlet weak var repeatPassword: HNInputField!
    @IBOutlet weak var tipLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.saveButton
        setupInputField(current)
        setupInputField(newPassword, validate: true)
        setupInputField(repeatPassword, validate: true)
        current.delegate = self
        newPassword.delegate = self
        repeatPassword.delegate = self
        current.addTarget(self, action: #selector(inputDidChange(textField:)), for: .editingChanged)
        newPassword.addTarget(self, action: #selector(inputDidChange(textField:)), for: .editingChanged)
        repeatPassword.addTarget(self, action: #selector(inputDidChange(textField:)), for: .editingChanged)
        saveButton.isEnabled = false
        title = NSLocalizedString("Password", comment: "Password")
    }

    @IBAction func onSave(_ sender: Any) {
        view.endEditing(true)
        
        guard let currentPwd = current.text, currentPwd != "" else {
            HNMessage.showError(message: NSLocalizedString("Input current password.", comment: "Input current password."))
            current.becomeFirstResponder()
            return
        }
        
        guard let newPwd = newPassword.text, newPwd != "", repeatPassword.text == newPwd else {
            HNMessage.showError(message: WLCopy.confirmPassowrdTip)
            newPassword.text = nil
            repeatPassword.text = nil
            newPassword.becomeFirstResponder()
            return
        }
        
        WaylensClientS.shared.changePassword(current: currentPwd, new: newPwd) { [weak self] (result) in
            if result.isSuccess {
                HNMessage.showSuccess(message: NSLocalizedString("Password changed", comment: "Password changed"))
                #if FLEET
                AccountControlManager.shared.keyChainMgr.onLogOut()
                AppViewControllerManager.gotoLogin()
                #else
                self?.navigationController?.popViewController(animated: true)
                #endif
            } else {
                HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Fail to change password", comment: "Fail to change password"))
            }
        }
    }
    
    @IBAction func onForgot(_ sender: Any) {
        let container = SignInContainerViewController.createViewController()
        container.notRefresh = true
        let vc = ForgotStepOneViewController.createViewController()
        vc.emailText = AccountControlManager.shared.keyChainMgr.email
        vc.emailFixed = true
        container.setRoot(vc)

        if #available(iOS 13.0, *) {
            container.modalPresentationStyle = .fullScreen
        }

        present(container, animated: true, completion: nil)
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == current {
            newPassword.becomeFirstResponder()
        } else if textField == newPassword {
            repeatPassword.becomeFirstResponder()
        } else {
            repeatPassword.resignFirstResponder()
            onSave(repeatPassword as Any)
        }
        return true
    }
    
    @objc func inputDidChange(textField: HNInputField) {
        if textField == newPassword {
            textField.isValid = textField.text?.isValidPassword() ?? false
        } else if textField == repeatPassword {
            textField.isValid = textField.text?.isValidPassword() ?? false && textField.text == newPassword.text
        }
        saveButton.isEnabled = !(current.text?.isEmpty ?? true) && newPassword.isValid && repeatPassword.isValid
    }
}

