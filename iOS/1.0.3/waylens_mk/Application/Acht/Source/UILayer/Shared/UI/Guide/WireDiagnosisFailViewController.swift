//
//  WireDiagnosisFailViewController.swift
//  Acht
//
//  Created by Chester Shen on 5/31/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class WireDiagnosisFailViewController: BlankBaseViewController {

    @IBOutlet weak var guideButton: UIButton!
    @IBOutlet weak var mainButton: UIButton!
    static func createViewController() -> WireDiagnosisFailViewController {
        let vc = WireDiagnosisFailViewController(nibName: "WireDiagnosisFailViewController", bundle: nil)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guideButton.addUnderline()
        
        initHeader(text: NSLocalizedString("Power Cord Test", comment: "Power Cord Test"), leftButton: true)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onGuideButton(_ sender: Any) {
        let vc = BaseWebViewController()
        vc.title = NSLocalizedString("FAQ", comment: "FAQ")
        vc.url = URL(string: "\(UserSetting.shared.webServer.rawValue)/support/faq/28/33/2938?webview=1")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Try again
    @IBAction func onMainButton(_ sender: Any) {
        for vc in navigationController!.viewControllers {
            if vc is WireDiagnosisPrepareViewController {
                navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }
    
    /// Fix it later
    @IBAction func onExit(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.App.powerTestDone, object: NSNumber(value: false))
        WLBonjourCameraListManager.shared.currentCamera?.setMountACCTrust(false)

        #if FLEET
        if parent?.flowGuide != nil {
            parent?.flowGuide?.nextStep()
        } else {
            for vc in navigationController!.viewControllers {
                if (vc is PCTCableTypeViewController) || (vc is WireDiagnosisPrepareViewController) {
                    if let previousViewController = vc.previousViewControllerInNavigationStack {
                        navigationController?.popToViewController(previousViewController, animated: true)
                        break
                    }
                }
            }
        }
        #else
        if let guideHelper = navigationController?.guideHelper {
            guideHelper.nextStep()
        } else {
            for vc in navigationController!.viewControllers {
                if (vc is PCTCableTypeViewController) || (vc is WireDiagnosisPrepareViewController) {
                    if let previousViewController = vc.previousViewControllerInNavigationStack {
                        navigationController?.popToViewController(previousViewController, animated: true)
                        break
                    }
                }
            }
        }
        #endif

    }

}
