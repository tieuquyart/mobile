//
//  SetupStepThreeViewController.swift
//  Acht
//
//  Created by Chester Shen on 8/8/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class SetupStepThreeViewController: BlankBaseViewController, WLCameraSettingsDelegate {
    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var password: UITextField!
    private var preview: CameraPreview?
    private var camera: UnifiedCamera?

    static func createViewController() -> SetupStepThreeViewController {
        let vc = UIStoryboard(name: "Setup", bundle: nil).instantiateViewController(withIdentifier: "SetupStepThreeViewController")
        return vc as! SetupStepThreeViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        title = NSLocalizedString("Camera Setup", comment: "Camera Setup")

        let vc = CameraPreview.createViewController()
        preview = vc
        previewContainer.addSubview(vc.view)
        vc.view.frame = previewContainer.bounds
        vc.setupState = .settingUp
        addChild(vc)
        vc.didMove(toParent: self)

        actionButton.isHidden = true
        password.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceChanged), name: NSNotification.Name.WLCurrentCameraChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onRecordStateChanged), name: Notification.Name.Local.recordState, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshCameraPreview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        preview?.hide()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func applyTheme() {
        super.applyTheme()

        actionButton.backgroundColor = UIColor.semanticColor(.tint(.primary))
    }
    
    @IBAction func onDone(_ sender: UIButton) {
        sender.setEnabled(enabled: false)
        camera?.name = preview?.nameTextField.text

        #if FLEET
        if parent?.flowGuide != nil {
            parent?.flowGuide?.nextStep()
        } else {
            continueGuide()
            quit()
        }
        #else
        if camera?.iccid?.isEmpty == false && UnifiedCameraManager.shared.cameraForSN(camera!.sn)?.ownerUserId == AccountControlManager.shared.keyChainMgr.userID {
            camera?.reportICCID(completion: nil)
            quit()
        } else {
            sender.setTitle(NSLocalizedString("Binding", comment: "Binding"), for: .normal)
            HNMessage.show()
            camera?.bind(password: camera?.local?.password ?? "", completion: { [weak self, camera] (result) in
                if result.isSuccess || result.error?.asAPIError == .deviceBoundToSelf {
                    if camera?.supports4g == true {
                        if let iccid = camera?.local?.iccid, !iccid.isEmpty {
                            camera?.reportICCID(completion: { (result) in
                                HNMessage.dismiss()
                                if result.isSuccess {
                                    self?.continueGuide()
                                    self?.quit()
                                } else {
                                    self?.resetActionButton()
                                    HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("SIM card error", comment: "SIM card error"))
                                }
                            })
                        } else {
                            self?.resetActionButton()
                            HNMessage.showError(message: WLCopy.simCardNotDetected)
                        }
                    } else {
                        HNMessage.dismiss()
                        self?.continueGuide()
                        self?.quit()
                    }
                } else {
                    self?.resetActionButton()
                    HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Bind Failed", comment: "Bind Failed"), to: self?.navigationController)
                }
            })
        }
        #endif
    }
    
    func quit() {
        if let _ = presentingViewController {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popToRootViewController(animated: false)
        }
    }
    
    func continueGuide() {
        if let guideHelper = navigationController?.guideHelper {
            guideHelper.nextStep()
        }
    }

    func resetForLosingCameraConnection() {
        preview?.hide()
        preview?.camera = nil
        camera = nil
        actionButton.isHidden = true
    }

    private func resetActionButton() {
        #if FLEET
        if parent?.flowGuide != nil {
            actionButton.setTitle(NSLocalizedString("Next", comment: "Next"), for: .normal)
        } else {
            actionButton.setTitle(NSLocalizedString("Done", comment: "Done"), for: .normal)
        }
        #else
        actionButton.setTitle(NSLocalizedString("Done", comment: "Done"), for: .normal)
        #endif
        actionButton.setEnabled(enabled: true)
    }

    private func refreshCameraPreview() {
        camera?.local?.settingsDelegate = nil
        for local in WLBonjourCameraListManager.shared.cameraList {
            if ((local.productSerie != .horn) &&
                (local.productSerie != .saxhorn)
                ) {
                continue
            }
            local.settingsDelegate = self
            if local.password ?? "" == "" {
                local.getPassword()
            }
            camera = UnifiedCamera(local: local, remote: nil)
            preview?.isActive = true
            preview?.camera = camera
            preview?.show()

            #if FLEET
            if camera?.featureAvailability.isMultiInstallationModesAvailable == false {
                preview?.sloganLabel.text = nil
            }
            #endif

            if actionButton.isHidden {
                #if FLEET
                if parent?.flowGuide != nil {
                    actionButton.setTitle(NSLocalizedString("Next", comment: "Next"), for: .normal)
                } else {
                    actionButton.setTitle(NSLocalizedString("Done", comment: "Done"), for: .normal)
                }
                #else
                actionButton.setTitle(NSLocalizedString("Done", comment: "Done"), for: .normal)
                #endif

                actionButton.isHidden = false
                actionButton.alpha = 0
                UIView.animate(withDuration: 0.4, delay: 1.0, options: [.curveEaseInOut], animations: {
                    self.actionButton.alpha = 1.0
                })
            }
            return
        }
        resetForLosingCameraConnection()
    }

    // Notification
    @objc func onDeviceChanged() {
        navigationController?.popToViewControllerWhichIsKind(of: SetupStepTwoViewController.self, animated: false)
    }

    @objc func onRecordStateChanged() {
        refreshCameraPreview()
    }
}
