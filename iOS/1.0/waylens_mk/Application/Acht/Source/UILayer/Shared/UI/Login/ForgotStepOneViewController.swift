//
//  ForgotStepOneViewController.swift
//  Acht
//
//  Created by Chester Shen on 9/19/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class ForgotStepOneViewController: AccountPageViewController, UITextFieldDelegate {
    @IBOutlet private weak var mainButton: HNMainButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var email: HNInputField!
    @IBOutlet weak var backButton: UIButton!
    
    var forgottenEmails = Set<String>()
    var emailText: String? {
        didSet {
            email?.text = emailText
        }
    }
    var emailFixed: Bool = false
    
    static func createViewController() -> ForgotStepOneViewController {
        let vc = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "ForgotStepOneViewController")
        return vc as! ForgotStepOneViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInputField(email)
        email.text = emailText

        #if FLEET
        titleLabel.text = NSLocalizedString("Change Password", comment: "Change Password")
        #else
        titleLabel.text = NSLocalizedString("Forgot Password", comment: "Forgot Password")
        #endif

        refreshUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !emailFixed {
            email.becomeFirstResponder()
        }
    }

    func refreshUI() {
        email.isEnabled = !emailFixed
        detailLabel.text = (emailFixed ? "" : NSLocalizedString("Please enter your email address used to create your Waylens account. ", comment: "Please enter your email address used to create your Waylens account. ")) + NSLocalizedString("We will send you a verification code shortly.", comment: "We will send you a verification code shortly.")
    }
    
    @IBAction func onMain(_ sender: Any) {
        guard let emailText = email.text, !emailText.isEmpty else {
            HNMessage.showError(message: NSLocalizedString("Input your email address", comment: "Input your email address"), to: nil)
            return
        }
        if forgottenEmails.contains(emailText) {
            let vc = ForgotStepTwoViewController.createViewController()
            vc.emailText = emailText
            self.container?.push(vc)
        } else {
            HNMessage.show()
            WaylensClientS.shared.requestPasswordReset(email: emailText) { [weak self] (result) in
                if result.isSuccess {
                    self?.container?.didForgot()
                    HNMessage.dismiss()
                    self?.forgottenEmails.insert(emailText)
                    let vc = ForgotStepTwoViewController.createViewController()
                    vc.emailText = emailText
                    self?.container?.push(vc)
                } else {
                    HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Fail to send verification", comment: "Fail to send verification"), to: nil)
                    if let error = result.error?.asAPIError, error == .notReachMinRetryInterval || error == .exceedMaxRetryLimit {
                        if self?.container?.recentForgotTime == nil {
                            self?.container?.didForgot()
                        }
                        self?.forgottenEmails.insert(emailText)
                        let vc = ForgotStepTwoViewController.createViewController()
                        vc.emailText = emailText
                        self?.container?.push(vc)
                    }
                }
            }
        }
    }

    @IBAction func onBack(_ sender: Any) {
        container?.pop()
    }
    
    // MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onMain(mainButton as Any)
        return true
    }

}
