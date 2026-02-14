//
//  LoginViewController.swift
//  Acht
//
//  Created by Chester Shen on 9/19/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class LoginViewController: AccountPageViewController, UITextFieldDelegate {
   
    
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var mainButton: HNMainButton!
    @IBOutlet weak var username: HNInputField!
    @IBOutlet weak var password: HNInputField!
    @IBOutlet weak var alternateButton: UIButton!
    let api = SessionService.shared
    
    var emailText: String? {
        didSet {
            username?.text = emailText
        }
    }
    
    static func createViewController() -> LoginViewController {
        #if FLEET
        let vc = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController-Fleet")
        #else
        let vc = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        #endif
        return vc as! LoginViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        skipButton.setTitle("", for: .normal)
        setupInputField(username)
        setupInputField(password)
        username.placeholder = "User"
        username.text = emailText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func onMainButton(_ sender: Any) {
      
        view.endEditing(true)
        guard let usernameText = username.text, !usernameText.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your email address", comment: "Input your email address"), to: nil)
            return
        }
        guard let passwordText = password.text, !passwordText.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your password", comment: "Input your password"), to: nil)
            return
        }
        HNMessage.show()

        UserSetting.shared.lastEmail = usernameText

        #if FLEET
//        let deviceToken = RemoteNotificationController.shared.remoteNotificationToken
        api.login(name: usernameText, password: passwordText, completion: { [weak self] (_result) in
            switch _result {
            case .success(let dict):
                if let data = dict["data"] as? JSON {
                    
                    
                    if  let role = data["roleNames"] as? [String] {
                        if (role[0] == "FLEETADMIN") {
                          
                            HNMessage.dismiss()
                            AccountControlManager.shared.keyChainMgr.onLogInMK(data)
                            self?.container?.refreshUI(animated:true)
                            
                        } else {
                            HNMessage.showError(message: _result.error?.localizedDescription ?? NSLocalizedString("Login Failed Roles", comment: "Login Failed Roles"), to: self?.navigationController)
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
        
       
    
//        WaylensClientS.shared.login(usernameText, password: passwordText, deviceToken: deviceToken) { [weak self] (result) in
//            if result.isSuccess {
//                HNMessage.dismiss()
//                self?.container?.refreshUI(animated:true)
//            } else {
//                HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Login Failed", comment: "Login Failed"), to: self?.navigationController)
//            }
//        }
        #else
        WaylensClientS.shared.login(usernameText, password: passwordText) { [weak self] (result) in
            if result.isSuccess {
                HNMessage.dismiss()
                self?.container?.refreshUI(animated:true)
            } else {
                HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Login Failed", comment: "Login Failed"), to: self?.navigationController)
            }
        }
        #endif

    }
    
    @IBAction func onAlternateButton(_ sender: Any) {
        let vc = SignUpViewController.createViewController()
        self.container?.setRoot(vc)
    }
    
    @IBAction func onForget(_ sender: Any) {
        let vc = ForgotStepOneViewController.createViewController()
        vc.emailText = username.text
        container?.push(vc)
    }

    @IBAction func onSkipLogIn(_ sender: Any) {
//        AccountControlManager.shared.skipLogin()
        appDelegate.rootTabBarController()
      //  container?.quit(animated: true, completion: nil)
    }
    
    // MARK: - UITextField Delegate
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
