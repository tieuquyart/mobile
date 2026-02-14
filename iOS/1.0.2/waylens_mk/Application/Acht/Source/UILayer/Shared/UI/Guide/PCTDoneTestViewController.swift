//
//  PCTDoneTestViewController.swift
//  Acht
//
//  Created by forkon on 2019/2/22.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class PCTDoneTestViewController: BaseViewController {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    var vehicleType: VehicleType!

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        title = NSLocalizedString("Power Cord Test", comment: "Power Cord Test")
        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
        
        applySetting()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshUI()
    }

    override func applyTheme() {
        super.applyTheme()

        doneButton.setBackgroundImageColor(UIColor.semanticColor(.tint(.primary)), disabledColor: UIColor.semanticColor(.background(.buttonDisabled)))
    }

    func refreshUI() {
        let method = (vehicleType == .traditional ? DrivingDetectionMethod.vehiclePower.name : DrivingDetectionMethod.vehicleMovement.name)
        
        let attributedText = String(format: NSLocalizedString("Your Secure360 camera will use xx to decide if the vehicle is driving or parked.", comment: "Your Secure360 camera will use %@ to decide if the vehicle is driving or parked."), method)
            .wl.mutableAttributed(with:
                [
                    NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12.0),
                    NSAttributedString.Key.foregroundColor : UIColor.semanticColor(.label(.primary))
                ]
            )
            .addAttributes(
                [
                    NSAttributedString.Key.foregroundColor : UIColor.semanticColor(.label(.quaternary))
                ],
                for: method
        )
        
        descriptionLabel.attributedText = attributedText

        #if FLEET
        if parent?.flowGuide != nil {
            doneButton.setTitle(NSLocalizedString("Next", comment: "Next"), for: .normal)
        } else {
            doneButton.setTitle(NSLocalizedString("Done", comment: "Done"), for: .normal)
        }
        #else
        doneButton.setTitle(NSLocalizedString("Done", comment: "Done"), for: .normal)
        #endif

    }
    
    func applySetting() {
        switch vehicleType {
        case .electric?, .hybridPlugin?:
            WLBonjourCameraListManager.shared.currentCamera?.setMountACCTrust(false)
        case .traditional?:
            WLBonjourCameraListManager.shared.currentCamera?.setMountACCTrust(true)
        default:
            break
        }
        WLBonjourCameraListManager.shared.currentCamera?.getMountACCTrust()
        NotificationCenter.default.post(name: Notification.Name.App.powerTestDone, object: NSNumber(value: false))
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        #if FLEET
        if parent?.flowGuide != nil {
            parent?.flowGuide?.nextStep()
        } else {
            guard let navigationController = navigationController else {
                return
            }

            var toVCIndex: Int? = nil
            for (index, vc) in navigationController.viewControllers.enumerated() {
                if vc is PCTCableTypeViewController {
                    toVCIndex = max(index - 1, 0)
                    break
                }
            }

            if let toVCIndex = toVCIndex {
                navigationController.popToViewController(navigationController.viewControllers[toVCIndex], animated: true)
            }
        }
        #else
        if let guideHelper = navigationController?.guideHelper {
            guideHelper.nextStep()
        } else {
            guard let navigationController = navigationController else {
                return
            }

            var toVCIndex: Int? = nil
            for (index, vc) in navigationController.viewControllers.enumerated() {
                if vc is PCTCableTypeViewController {
                    toVCIndex = max(index - 1, 0)
                    break
                }
            }

            if let toVCIndex = toVCIndex {
                navigationController.popToViewController(navigationController.viewControllers[toVCIndex], animated: true)
            }
        }
        #endif
    }

}
