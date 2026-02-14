//
//  SignUpVerifyViewController.swift
//  Acht
//
//  Created by Chester Shen on 9/20/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation

class SignUpVerifyViewController: AccountPageViewController {

    @IBOutlet weak var resendButton: HNMainButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    let resendInterval:TimeInterval = 60
    var justSent: Bool = false
    
    var checkTimer: WLTimer?
    
    static func createViewController() -> SignUpVerifyViewController {
        let vc = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "SignUpVerifyViewController")
        return vc as! SignUpVerifyViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkTimer = WLTimer.init(reference: self, interval: 3.0, repeat: false, block: { [weak self] in
            self?.checkVerified()
        })
        backButton.titleLabel?.numberOfLines = 2
        textLabel.text = String(format: NSLocalizedString("verify_your_email_description_format", comment: "We sent you a verification email. Please follow the instructions in that email to verify your account %@."), AccountControlManager.shared.keyChainMgr.email!)
        resendButton.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if container?.resendTimer?.isValid ?? false {
            refreshCountDown()
        } else if justSent {
            setupCountDown()
            container?.resendTimer?.start()
        }
        checkTimer?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        checkTimer?.stop()
    }
    
    func refreshCountDown() {
        var remaining = container?.resendTimer?.remainingCount ?? 0
        if let lastTime = container?.resendTimer?.startTime {
            remaining = min(remaining, Int(resendInterval + lastTime.timeIntervalSinceNow))
            if remaining <= 0 {
                container?.resendTimer?.stop()
            }
        }
        if remaining <= 0 {
            resendButton.isEnabled = true
        } else {
            if resendButton.isEnabled {
                resendButton.isEnabled = false
            }
            resendButton.setTitle(String(format: NSLocalizedString("Re-send Verification(%ds)", comment: "Re-send Verification(%ds)"), remaining), for: .disabled)
        }
    }
    
    func checkVerified() {
        checkTimer?.stop()
        WaylensClientS.shared.fetchProfile { [weak self] (result) in
            if result.isSuccess && AccountControlManager.shared.isVerified {
                let vc = UIStoryboard(name: "Setup", bundle: nil).instantiateViewController(withIdentifier: "SetupZero")
                self?.container?.showViewController(vc)
            } else {
                self?.checkTimer?.start()
            }
        }
    }
    
    private func setupCountDown() {
        resendButton.isEnabled = false
        resendButton.setTitle(NSLocalizedString("Re-send Verification", comment: "Re-send Verification"), for: .disabled)
        container?.resendTimer = WLTimer.init(reference: container ?? self, interval: 1.0, repeatTimes: Int(resendInterval), block: { [weak self] in
            self?.refreshCountDown()
        })
    }

    @IBAction func onBack(_ sender: Any) {
        checkTimer?.stop()
        WaylensClientS.shared.logout(completion: nil)
        let vc = SignUpViewController.createViewController()
        container?.setRoot(vc, animated: true)
    }
    
    @IBAction func onResend(_ sender: Any) {
        setupCountDown()
        WaylensClientS.shared.resendVerification { [weak self] (result) in
            if result.isFailure && result.error?.asAPIError == WLAPIError.networkError {
                self?.resendButton.isEnabled = true
            } else {
                self?.container?.resendTimer?.start()
            }
            if result.isFailure {
                HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Fail to re-send verification", comment: "Fail to re-send verification"))
            }
        }
    }
    
    @objc func didEnterBackground() {
        checkTimer?.stop()
    }
    
    @objc func willEnterForeground() {
        checkTimer?.start()
    }
}
