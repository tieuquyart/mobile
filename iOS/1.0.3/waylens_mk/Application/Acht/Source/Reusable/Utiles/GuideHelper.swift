//
//  GuideHelper.swift
//  Acht
//
//  Created by forkon on 2019/3/21.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

enum GuideState: Int, Equatable {
    case start = 0
    case addCamera
    case checkWire
    case choosePlan
    case checkNetwork
    case checkSDCard
    case showCamera
    case inCamera
    case showViewMode
    case showPanorama
    case showTimeline
    case showActionBar
    case congrats
    case end

    var inHome: Bool {
        return self.rawValue < GuideState.inCamera.rawValue
    }
    var inCamera: Bool {
        return self.rawValue >= GuideState.inCamera.rawValue && self != GuideState.end
    }
}

private typealias SetupCameraGuideStep = GuideState

final class GuideHelper {
    private static var _isToShowJustAfterAppLaunch: Bool = true
    private static var isToShowJustAfterAppLaunch: Bool {
        if _isToShowJustAfterAppLaunch {
            _isToShowJustAfterAppLaunch = false
            return true
        } else {
            return false
        }
    }

    private static var isGuideFlowSkipped: Bool {
        return UserSetting.shared.guideSwitch == .skipped
    }

    static var isGuideFlowFinished: Bool {
        return UserSetting.shared.guideState == .end
    }

    static var shouldContinueCameraDetailUIGuide: Bool {
        if UserSetting.shared.guideState.inCamera &&
            UIApplication.shared.statusBarOrientation == .portrait &&
            UserSetting.shared.guideSwitch != .skipped &&
            !isToShowJustAfterAppLaunch {
            return true
        }

        return false
    }

    private let guideFlow: [SetupCameraGuideStep] = [
        .start,
        .addCamera,
        .checkWire,
        .choosePlan,
        .checkNetwork,
        .checkSDCard,
        .showCamera,
        .inCamera
    ]

    private var currentStep: SetupCameraGuideStep {
        set {
            UserSetting.shared.guideState = newValue
        }
        get {
            return UserSetting.shared.guideState
        }
    }

    private weak var flowNavigationController: UINavigationController? = nil

    private var guidePresentingViewController: UIViewController? {
        return AppViewControllerManager.tabBarController
    }

    private lazy var goBackButton = UIBarButtonItem(image: UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(goBackButtonTapped(_:)))

    func startGuide() {
        guard !GuideHelper.isGuideFlowFinished else {
            return
        }

        if currentStep.inCamera {
            presentCameraDetailGuideViewController()
        } else {
            presentGuideViewController()
        }
    }

    func startGuideIfNeeded() {
        if appDelegate.firstLaunch.isFirstLaunch && GuideHelper.isToShowJustAfterAppLaunch {
            startGuide()
        } else {
            if GuideHelper.isToShowJustAfterAppLaunch && !GuideHelper.isGuideFlowFinished {
                GuideHelper.showContinueConfirmation { [weak self] in
                    self?.startGuide()
                }
            }
        }
    }

    func restartGuide() {
//        _isShownJustAfterAppLaunch = false
        UserSetting.shared.guideState = .start
        AppViewControllerManager.goHome()
        startGuide()
    }

    func nextStep() {
        var next: SetupCameraGuideStep?

        if let index = guideFlow.firstIndex(of: currentStep), index + 1 < guideFlow.count {
            next = guideFlow[index + 1]
        }

        currentStep = next ?? .end

        flowNavigationController?.dismiss(animated: true, completion: { [weak self] in
            self?.flowNavigationController = nil
        })

        if let next = next {
            switch next {
            case .addCamera:
                if cameraIsAdded(UnifiedCameraManager.shared.local) {
                    nextStep()
                    return
                }
            case .choosePlan:
                let camera = UnifiedCameraManager.shared.local

                if !(camera?.supports4g ?? false) {
                    nextStep()
                    return
                } else if camera?.remote?.hadSubscription ?? false {
                    nextStep()
                    return
                }
            case .checkNetwork:
                let camera = UnifiedCameraManager.shared.local

                if !(camera?.supports4g ?? false) {
                    nextStep()
                    return
                }
            case .checkSDCard:
                let camera = UnifiedCameraManager.shared.local

                guard let sdcardState = camera?.local?.storageState else {
                    nextStep()
                    return
                }

                if !(sdcardState == .error || camera?.local?.shouldFormat == true) && !(sdcardState == .noStorage) {
                    nextStep()
                    return
                }
            case .showCamera:
                AppViewControllerManager.goHome()
                nextStep()
                return
            case .inCamera:
                presentCameraDetailGuideViewController()
                return
            default:
                break
            }

            presentGuideViewController()
        }
    }

    #if !FLEET
    static func continueGuide() {
        //        UserSetting.shared.guideSwitch = .ongoing
        AppViewControllerManager.goHome()
        appDelegate.guideHelper.startGuide()
    }
    #endif

    static func showContinueConfirmation(with continueHandler: @escaping () -> Void) {
        let alert = GuideSkipAlertViewController.createViewController()
        alert.image = UIImage(named: "image_puzzle")
        alert.text = NSLocalizedString("continue_guide", comment: "continue guide tip")
        alert.addActionsInRow([HNAlertAction(title: NSLocalizedString("Not now", comment: "Not now"), style: .normal, handler: {
            UserSetting.shared.guideSwitch = .skipped
        }), HNAlertAction(title: NSLocalizedString("Continue", comment: "Continue"), style: .primary, handler: {
            UserSetting.shared.guideSwitch = .ongoing
            continueHandler()
        })])
        alert.addAction(HNAlertAction(title: NSLocalizedString("Never", comment: "Never"), style: .cancel, handler: {
            UserSetting.shared.guideState = .end
        }))
        alert.modalTransitionStyle = .crossDissolve
        alert.modalPresentationStyle = .overCurrentContext
        AppViewControllerManager.tabBarController?.present(alert, animated: true, completion: nil)
    }

}

extension GuideHelper {

    private func presentGuideViewController() {
        let guideVC = GuideViewController.createViewController()

        guideVC.actionHandler = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if strongSelf.currentStep == .choosePlan {
                if let camera = UnifiedCameraManager.shared.local {
                    if let iccid = camera.local?.iccid, !iccid.isEmpty {
                        HNMessage.show()
                        camera.reportICCID { (result) in
                            if result.isSuccess {
                                HNMessage.dismiss()
                                sharedApplication.open(URL(string: "\(UserSetting.shared.webServer.rawValue)/my/device/\(camera.sn)/4g_subscription/plans")!, options: [:], completionHandler: nil)
                                guideVC.dismiss(animated: true) {
                                    strongSelf.nextStep()
                                }
                            } else {
                                if let error = result.error {
                                    HNMessage.showError(message: error.localizedDescription)
                                }
                            }
                        }
                    } else {
                        HNMessage.showError(message: WLCopy.simCardNotDetected)
                    }
                }
            } else {
                guideVC.dismiss(animated: true) {
                    switch strongSelf.currentStep {
                    case .start, .congrats:
                        strongSelf.nextStep()
                    default:
                        let stepVC = strongSelf.makeViewController(for: strongSelf.currentStep)
                        stepVC.navigationItem.leftBarButtonItem = strongSelf.goBackButton

                        let flowNavigationController = stepVC.embedInNavigationController()
                        flowNavigationController.modalPresentationStyle = .overFullScreen
                        flowNavigationController.modalTransitionStyle = .crossDissolve
                        flowNavigationController.guideHelper = self

                        strongSelf.flowNavigationController = flowNavigationController

                        strongSelf.guidePresentingViewController?.present(strongSelf.flowNavigationController!, animated: true, completion: nil)
                    }
                }
            }
        }

        guidePresentingViewController?.present(guideVC, animated: true, completion: nil)
    }

    private func presentCameraDetailGuideViewController() {
        AppViewControllerManager.goHome()
        (AppViewControllerManager.homeViewController as? HNCameraDetailViewController)?.showGuide()
    }

    private func makeViewController(for step: SetupCameraGuideStep) -> UIViewController {
        var stepVC: UIViewController!

        switch step {
        case .addCamera:
            stepVC = SetupStepOneViewController.createViewController()
        case .checkWire:
            let camera = UnifiedCameraManager.shared.local

            if camera?.featureAvailability.isUntrustACCWireSupportAvailable == true {
                let vc = PCTCableTypeViewController.createViewController()
                vc.camera = camera
                stepVC = vc
            } else {
                let vc = WireDiagnosisPrepareViewController.createViewController()
                vc.camera = camera
                stepVC = vc
            }
        case .choosePlan:
            if let camera = UnifiedCameraManager.shared.local {
                stepVC = SafariViewController(url: URL(string: "\(UserSetting.shared.webServer.rawValue)/my/device/\(camera.sn)/4g_subscription/plans")!)
            }
        case .checkNetwork:
            let vc = NetworkDiagnosisViewController.createViewController()
            vc.camera = UnifiedCameraManager.shared.local
            stepVC = vc
        case .checkSDCard:
            if let camera = UnifiedCameraManager.shared.local {
                let vc = HNCSSDCardViewController.createViewController()
                vc.camera = camera
                stepVC = vc
            }
        default:
            stepVC = GuideViewController.createViewController()
        }

        return stepVC
    }

    private func cameraIsAdded(_ camera: UnifiedCamera?) -> Bool {
        #if FLEET
        return camera != nil
        #else
        return camera != nil && AccountControlManager.shared.isAuthed && AccountControlManager.shared.keyChainMgr.userID == camera?.ownerUserId
        #endif
    }

    @objc private func goBackButtonTapped(_ sender: UIBarButtonItem) {
        flowNavigationController?.dismiss(animated: true, completion: { [weak self] in
            self?.flowNavigationController = nil
        })
        presentGuideViewController()
    }


}

extension UINavigationController {

    fileprivate struct AssociatedKeys {
        static var guideHelper: UInt8 = 8
    }

    weak var guideHelper: GuideHelper? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.guideHelper, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.guideHelper) as? GuideHelper
        }
    }

}
