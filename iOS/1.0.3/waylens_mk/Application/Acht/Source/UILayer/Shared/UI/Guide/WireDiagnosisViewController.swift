//
//  WireDiagnosisViewController.swift
//  Acht
//
//  Created by Chester Shen on 5/15/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import RxSwift
import AudioToolbox
import WaylensFoundation

class WireDiagnosisViewController: BlankBaseViewController {
//    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var powerIndicator: UIImageView!
    @IBOutlet weak var stepOneLabel: UILabel!
    @IBOutlet weak var stepTwoLabel: UILabel!
    @IBOutlet weak var stepOneIcon: UIImageView!
    @IBOutlet weak var stepTwoIcon: UIImageView!
    @IBOutlet weak var failButtonContainer: UIView!
    @IBOutlet weak var failButton: UIButton!
    @IBOutlet weak var stepsView: UIView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!

    private lazy var countDownTimer: WLTimer = WLTimer(reference: self, interval: 1.0, repeatTimes: 27) { [weak self] in
        self?.refreshDetailLabel()
    }

    private var remainingSeconds: Int = 0
    private let disposeBag = DisposeBag()

    private enum DiagnosisState {
        case notPrepared
        case stepOne
        case stepTwo
        case passed
        case failed
    }
    
    private var state: DiagnosisState = .stepOne

    @objc var camera: UnifiedCamera? {
        didSet {
            camera?.rx.observeWeakly(Bool.self, #keyPath(UnifiedCamera.local.isParking))
                .subscribe(onNext: { [weak self] _ in
                    if self?.isViewLoaded ?? false {
                        self?.refreshState()
                    }
                }).disposed(by: disposeBag)
        }
    }

    static func createViewController() -> WireDiagnosisViewController {
        let vc = WireDiagnosisViewController(nibName: "WireDiagnosisViewController", bundle: nil)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
    
        initHeader(text: NSLocalizedString("Power Cord Test", comment: "Power Cord Test"), leftButton: true)

        doneButton.applyMainStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDisconnected), name: Notification.Name.UnifiedCameraManager.localDisconnected, object: nil)
        refreshState()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func applyTheme() {
        super.applyTheme()

        refreshUI()
    }
    
    private func nextState() -> DiagnosisState {
        guard let parking = camera?.local?.isParking else { return .failed }
        let accOn = !parking
        switch state {
        case .stepOne:
            if camera?.viaWiFi ?? false {
                if accOn {
                    return .stepOne
                } else {
                    return .stepTwo
                }
            } else { // wifi disconnected
                return .failed
            }
        case .stepTwo:
            if camera?.viaWiFi ?? false {
                if accOn {
                    return .passed
                } else {
                    return .stepTwo
                }
            } else {
                return .notPrepared
            }
        default:
            return state
        }
    }
    
    @objc func deviceDisconnected() {
        refreshState()
    }
    
    @objc func refreshState() {
        let _state = nextState()
        if _state != state {
            if _state == .stepTwo {
                if camera?.featureAvailability.isKeepAliveWhileAppConnectAvailable == false {
                    countDownTimer.stop()
                }
            }
            state = _state
            if state == .stepTwo {
                if camera?.featureAvailability.isKeepAliveWhileAppConnectAvailable == false {
                    countDownTimer.start()
                }
            }
            if state == .stepTwo || state == .passed {
                AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate, nil)
            }
        }
        refreshUI()
    }
    
    func refreshDetailLabel() {
        if state == .stepTwo {
            let seconds = countDownTimer.remainingCount
            if seconds == 0 {
                detailLabel.text = NSLocalizedString("Power on your vehicle now", comment: "Power on your vehicle now")
                detailLabel.textColor = UIColor.semanticColor(.label(.tertiary))
            } else {
                let format: String = NSLocalizedString("Camera will sleep and lose connection after %ds", comment: "Camera will sleep and lose connection after %ds")
                detailLabel.text = String.localizedStringWithFormat(format, seconds)
                detailLabel.textColor = UIColor.semanticColor(.label(.primary))
            }
        }
    }

    func refreshUI() {
        stepsView.isHidden = false
        successLabel.isHidden = true
        failButtonContainer.isHidden = false
        doneButton.isHidden = true

        stepOneIcon.tintColor = UIColor.semanticColor(.label(.secondary))
        stepTwoIcon.tintColor = UIColor.semanticColor(.label(.secondary))

        switch state {
        case .stepOne:
            stepOneIcon.image = #imageLiteral(resourceName: "icon_step_one_s")
            stepTwoIcon.image = #imageLiteral(resourceName: "icon_step_two_n")
            stepOneLabel.textColor = UIColor.semanticColor(.label(.secondary))
            stepTwoLabel.textColor = UIColor.semanticColor(.label(.secondary)).withAlphaComponent(0.2)
            detailLabel.isHidden = true
            failButton.setTitle(NSLocalizedString("Vehicle is powered OFF", comment: "Vehicle is powered OFF"), for: .normal)
            powerIndicator.image = #imageLiteral(resourceName: "icon_powered_on")
            powerIndicator.alpha = 1
        case .stepTwo:
            stepOneIcon.image = #imageLiteral(resourceName: "icon_step_one_n")
            stepTwoIcon.image = #imageLiteral(resourceName: "icon_step_two_s")
            stepOneLabel.textColor = UIColor.semanticColor(.label(.secondary)).withAlphaComponent(0.2)
            stepTwoLabel.textColor = UIColor.semanticColor(.label(.secondary))

            if camera?.featureAvailability.isKeepAliveWhileAppConnectAvailable == false {
                detailLabel.isHidden = false
                refreshDetailLabel()
            }

            failButton.setTitle(NSLocalizedString("Vehicle is powered ON", comment: "Vehicle is powered ON"), for: .normal)
            UIView.animate(withDuration: 0.5, animations: {
                self.powerIndicator.alpha = 0
            }, completion: nil)
        case .passed:
            stepsView.isHidden = true
            successLabel.isHidden = false
            successLabel.text = NSLocalizedString("direct_wire_connection_finished_verifying", comment: "Finished.\nYour Direct Wire connection is verified!")
            doneButton.isHidden = false
            failButtonContainer.isHidden = true
            powerIndicator.image = #imageLiteral(resourceName: "icon_wire_test_success")
            UIView.animate(withDuration: 0.5, animations: {
                self.powerIndicator.alpha = 1
            }, completion: nil)
        case .failed:
            if self == navigationController?.topViewController {
                onFail(self)
            }
        case .notPrepared:
            if self == navigationController?.topViewController {
                navigationController?.popViewController(animated: false)
            }
        }
    }
    
    @IBAction func onDone(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.App.powerTestDone, object: NSNumber(value: true))

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
    
    @IBAction func onFail(_ sender: Any) {
        navigationController?.pushViewController(WireDiagnosisFailViewController.createViewController(), animated: true)
        state = .notPrepared
    }

}
