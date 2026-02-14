//
//  SignUpViewController.swift
//  Acht
//
//  Created by Chester Shen on 9/18/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class SignUpViewController: AccountPageViewController, UITextFieldDelegate {

    @IBOutlet weak var mainButton: HNMainButton!
    @IBOutlet weak var username: HNInputField!
    @IBOutlet weak var password: HNInputField!
    @IBOutlet weak var alternateButton: UIButton!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var agreeLabel: UILabel!
    @IBOutlet weak var agreeButton: UIButton!
    
    static func createViewController() -> SignUpViewController {
        let vc = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController")
        return vc as! SignUpViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainButton.layer.cornerRadius = 2
        mainButton.clipsToBounds = true
        setupInputField(username, validate: true)
        setupInputField(password, validate: true)
        tipLabel.text = ""
        
        let agreeText = NSLocalizedString("I agree to", comment: "I agree to") + NSLocalizedString("Waylens Agreement", comment: "Waylens Agreement")
        let attriText = NSMutableAttributedString(string: agreeText)
        let range = (agreeText as NSString).range(of: NSLocalizedString("Waylens Agreement", comment: "Waylens Agreement"))
        attriText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        agreeLabel.attributedText = attriText
        agreeLabel.isUserInteractionEnabled = true
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(onTapAgreeLabel(gesture:)))
        agreeLabel.addGestureRecognizer(tapGuesture)
    }

    @IBAction func onMainButton(_ sender: Any) {
        view.endEditing(true)
        guard let usernameText = username.text, usernameText.isValidEmail() else {
            HNMessage.showError(message: WLCopy.emailTip)
            return
        }
        guard let passwordText = password.text,  passwordText.isValidPassword() else {
            HNMessage.showError(message: WLCopy.passwordTip)
            return
        }
        HNMessage.show()
        WaylensClientS.shared.signup(username.text!, password: password.text!) { [weak self] (result) in
            if result.isSuccess {
                HNMessage.dismiss()
                let vc = SignUpVerifyViewController.createViewController()
                vc.justSent = true
                self?.container?.push(vc)
            } else {
                HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Sign Up Failed", comment: "Sign Up Failed"))
            }
        }
    }
    
    @IBAction func onAlternateButton(_ sender: Any) {
        let vc = LoginViewController.createViewController()
        self.container?.setRoot(vc)
    }
    
    @IBAction func onAgreeButton(_ sender: Any) {
        agreeButton.isSelected = !agreeButton.isSelected
        mainButton.isEnabled = agreeButton.isSelected
    }
    
    @objc func onTapAgreeLabel(gesture: UITapGestureRecognizer) {
        let range = (agreeLabel.text! as NSString).range(of: NSLocalizedString("Waylens Agreement", comment: "Waylens Agreement"))
        if gesture.didTapAttributedTextInLabel(label: agreeLabel, inRange: range) {
            container?.notRefresh = true
            container?.showAgreementViewController()
        } else {
            onAgreeButton(agreeLabel as Any)
        }
    }
    
    // MARK: - UITextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let oldString = textField.text as NSString? {
            let newString = oldString.replacingCharacters(in: range, with: string) as String
            if textField == username {
                username.isValid = newString.isValidEmail()
                tipLabel.text = username.isValid ? "" : WLCopy.emailTip
            } else if textField == password {
                password.isValid = newString.isValidPassword()
                tipLabel.text = password.isValid ? "" : WLCopy.passwordTip
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == username {
            password.becomeFirstResponder()
        } else {
            password.resignFirstResponder()
            onMainButton(mainButton as Any)
        }
        return true
    }
}
