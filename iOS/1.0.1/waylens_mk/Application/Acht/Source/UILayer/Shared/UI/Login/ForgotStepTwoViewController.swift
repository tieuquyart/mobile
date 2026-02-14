//
//  ForgotStepTwoViewController.swift
//  Acht
//
//  Created by Chester Shen on 9/19/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation

class ForgotStepTwoViewController: AccountPageViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mainButton: HNMainButton!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var input: HNInputField!
    let resendInterval:TimeInterval = 60
    var forgotTimer: WLTimer?
    var emailText: String?
    
    static func createViewController() -> ForgotStepTwoViewController {
        let vc = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "ForgotStepTwoViewController")
        return vc as! ForgotStepTwoViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInputField(input)
        input.addTarget(self, action: #selector(inputDidChange(textField:)), for: .editingChanged)
        mainButton.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        input.text = nil
        setupTimer()
        refreshCountDown()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        forgotTimer?.stop()
    }
    
    func setupTimer() {
        forgotTimer?.stop()
        if let lastTime = container?.recentForgotTime {
            let remaining = Int(resendInterval + lastTime.timeIntervalSinceNow)
            if remaining > 0 {
                forgotTimer = WLTimer(reference: self, interval: 1.0, repeatTimes: remaining, block: { [weak self] in
                    self?.refreshCountDown()
                })
                forgotTimer?.start()
            }
        }
    }
    
    @IBAction func onMain(_ sender: Any) {
        mainButton.setEnabled(enabled: false)
        mainButton.setTitle(NSLocalizedString("Re-send", comment: "Re-send"), for: .disabled)
        container?.didForgot()
        guard let emailText = emailText else { return }
        WaylensClientS.shared.requestPasswordReset(email: emailText) { [weak self] (result) in
            if result.isSuccess {
                self?.setupTimer()
            } else {
                if result.error?.asAPIError == .networkError {
                    self?.mainButton.setEnabled(enabled: true)
                }
                HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Fail to re-send verification", comment: "Fail to re-send verification"))
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        container?.pop()
    }
    
    func refreshCountDown() {
        if !isViewLoaded { return }
        var remaining = forgotTimer?.remainingCount ?? 0
        if let lastTime = container?.recentForgotTime {
            remaining = min(remaining, Int(resendInterval + lastTime.timeIntervalSinceNow))
            if remaining <= 0 {
                forgotTimer?.stop()
            }
        }
        let count = (forgotTimer?.isValid ?? false) ? remaining : 0
        if count <= 0 {
            mainButton.setEnabled(enabled: true)
        } else {
            mainButton.setEnabled(enabled: false)
            mainButton.setTitle(String(format: NSLocalizedString("Re-send(%ds)", comment: "Re-send(%ds)"), count), for: .disabled)
        }
    }
    
    private func next(_ token: String) {
        let vc = ForgotStepThreeViewController.createViewController()
        vc.emailText = emailText
        vc.token = token
        container?.push(vc)
    }
    
    @objc func inputDidChange(textField: HNInputField) {
        if textField.text?.count == 6 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                self.next(textField.text!)
            }
        }
    }
    
}
