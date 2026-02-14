//
//  GuideViewController.swift
//  Acht
//
//  Created by Chester Shen on 5/16/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

protocol GuideController: AnyObject {
    var background: UIImageView! { get }
    func onAction()
    func onSkip()
}

class GuidePage: UIViewController {
    weak var controller: GuideController?
}

class GuideBasicViewController: UIViewController, GuideController {
    var background: UIImageView!
    var gradientLayer: CAGradientLayer?
    var state: GuideState {
        return UserSetting.shared.guideState
    }
    
    weak var presentedPage: GuidePage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        background = UIImageView()
        view.addSubview(background)
        background.frame = view.bounds
        background.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        background.image = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshUI()
    }
    
    func refreshUI() {
        // to override
    }
    
    func present(_ vc: GuidePage) {
        clearPage()
        vc.controller = self
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addChild(vc)
        vc.didMove(toParent: self)
        presentedPage = vc
        view.layoutIfNeeded()
        setGradientLayer()
    }
    
    func clearPage() {
        if let vc = presentedPage {
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
    }
    
    private func setGradientLayer() {
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            gradientLayer?.frame = self.background.bounds
            let color3 = UIColor(rgb: 0x1C95EB).cgColor
            let color2 = UIColor(rgb: 0x0F2447, a: 0.9).cgColor
            let color1 = UIColor(rgb: 0x0C102B, a: 0.85).cgColor
            gradientLayer?.colors = [color1, color2, color3]
            gradientLayer?.locations = [0.0, 0.33, 1.0]
            gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer?.endPoint = CGPoint(x: 0, y: 1)
            UIView.transition(
                with: background,
                duration: 0.6,
                options: .transitionCrossDissolve,
                animations: {
                    self.background.layer.addSublayer(self.gradientLayer!)
            },
                completion: nil
            )
        }
        if gradientLayer?.frame != background.bounds {
            gradientLayer?.frame = self.background.bounds
        }
    }
    
    func onAction() {
        // to override
    }
    
    func onSkip() {
        let alert = GuideSkipAlertViewController()
        alert.image = UIImage(named: "image_discontinue")
        alert.text = NSLocalizedString("skip_guide", comment: "skip guide tip")
        alert.addAction(HNAlertAction(title: NSLocalizedString("Continue tour", comment: "Continue tour"), style: .primary))
        alert.addAction(HNAlertAction(title: NSLocalizedString("Skip", comment: "Skip"), style: .cancel, handler: {
            UserSetting.shared.guideSwitch = .skipped
            self.dismiss(animated: true, completion: nil)
        }))
        alert.modalTransitionStyle = .crossDissolve
        alert.modalPresentationStyle = .overCurrentContext
        present(alert, animated: true, completion: nil)
    }
}

class GuideViewController: GuideBasicViewController {
    typealias ActionHandler = () -> ()

    static func createViewController() -> GuideViewController {
        let vc = GuideViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }

    var actionHandler: ActionHandler? = nil
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUI), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc override func refreshUI() {
        let camera = UnifiedCameraManager.shared.local
        
        switch state {
        case .start:
            let vc = GuideWelcomePage.createViewController(
                title: NSLocalizedString("Take a tour?", comment: "Take a tour?"),
                detail: NSLocalizedString("guide_welcome_page_detail", comment: "Thank you for choosing the Waylens Secure360, the breakthrough automotive security camera.\nLet's go through the basics of the camera and app!"),
                image: #imageLiteral(resourceName: "image_welcome"),
                button: NSLocalizedString("Get started", comment: "Get started")
            )
            present(vc)
        case .addCamera:
            let vc = GuideBasicPage.createViewController()
            vc.text = NSLocalizedString("Connect your Secure360 camera", comment: "Connect your Secure360 camera")
            vc.actionTitle = NSLocalizedString("Go", comment: "Go")
            present(vc)
        case .checkWire:
            let vc = GuideBasicPage.createViewController()
            vc.text = NSLocalizedString("Check power cord", comment: "Check power cord")
            vc.actionTitle = NSLocalizedString("Go", comment: "Go")
            present(vc)
        case .choosePlan:
            let vc = GuideBasicPage.createViewController()
            if let iccid = camera?.local?.iccid, !iccid.isEmpty {
                vc.text = NSLocalizedString("Subscribe a data plan", comment: "Subscribe a data plan")
                vc.actionTitle = NSLocalizedString("Go", comment: "Go")
            } else {
                vc.text = NSLocalizedString("Insert the SIM card and replug the cable.", comment: "Insert the SIM card and replug the cable.")
                vc.actionTitle = NSLocalizedString("OK", comment: "OK")
            }
            present(vc)
        case .checkNetwork:
            let vc = GuideBasicPage.createViewController()
            vc.text = NSLocalizedString("Check 4G network connection", comment: "Check 4G network connection")
            vc.actionTitle = NSLocalizedString("Go", comment: "Go")
            present(vc)
        case .checkSDCard:
            guard let sdcardState = camera?.local?.storageState else {
                break
            }
            if sdcardState == .error || camera?.local?.shouldFormat == true {
                // prompt to format sd card if sd card error
                let vc = GuideBasicPage.createViewController()
                vc.text = NSLocalizedString("Format your SD card", comment: "Format your SD card")
                vc.actionTitle = NSLocalizedString("Go", comment: "Go")
                present(vc)
            } else {
                let vc = GuideBasicPage.createViewController()
                vc.text = NSLocalizedString("Insert an SD card", comment: "Insert an SD card")
                vc.actionTitle = NSLocalizedString("OK", comment: "OK")
                present(vc)
            }
        case .congrats:
            let vc = GuideCongratsPage()
            present(vc)
        default:
            dismiss(animated: true, completion: nil)
        }
    }
   
    override func onAction() {
        actionHandler?()
    }
}
