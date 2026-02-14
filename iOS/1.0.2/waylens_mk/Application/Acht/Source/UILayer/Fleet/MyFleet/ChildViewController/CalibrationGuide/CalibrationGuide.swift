//
//  CalibrationGuide.swift
//  Fleet
//
//  Created by forkon on 2020/8/7.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

enum CalibrationGuideStep: FlowGuideStep, CaseIterable {
    case checkInstallationPosition
    case makeSureCameraOrientation
    case inputVehicleInfo
    case adjustCameraPosition
    case calib
}

class CalibrationGuide: NSObject, FlowGuide {
    public var parent: FlowGuide? = nil
    public fileprivate(set) var currentStep: CalibrationGuideStep?
    public var driverPosition: (x: Float, y: Float, z: Float) = (x: 0.0, y: 0.0, z: 0.0)

    private let guideFlow: [CalibrationGuideStep] = CalibrationGuideStep.allCases
    private let presenter: CalibrationGuidePresenter

    private var initialCameraSN: String? = nil

    public init(presenter: CalibrationGuidePresenter) {
        self.presenter = presenter
        super.init()
        self.presenter.flowGuide = self
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.WLCurrentCameraChange, object: nil)
    }

    public func start() {
        currentStep = guideFlow.first
        initialCameraSN = WLBonjourCameraListManager.shared.currentCamera?.sn

        if let currentStep = currentStep {
            presenter.present(currentStep, with: nil)
            setupCameraForCalibration()
            UIApplication.shared.isIdleTimerDisabled = true
            NotificationCenter.default.addObserver(self, selector: #selector(handleCurrentDeviceDidChangeNotification), name: NSNotification.Name.WLCurrentCameraChange, object: nil)
        }
    }

    public func nextStep() {
        nextStep(with: nil)
    }

    public func nextStep(with params: [AnyHashable : Any]?) {
        var next: CalibrationGuideStep?

        if let index = guideFlow.firstIndex(of: currentStep!), index + 1 < guideFlow.count {
            next = guideFlow[index + 1]
            presenter.present(next!, with: params)
        } else {
            // done, quit
            presenter.comeToAnEnd()
        }

        currentStep = next
    }

    public func backToFirstStep() {
        if let firstStep = guideFlow.first {
            presenter.present(firstStep, with: nil)
            currentStep = firstStep
        }
    }

}

//MARK: - Private

extension CalibrationGuide {

    fileprivate func updateCurrentStep(with index: Int) {
        guard index >= 0, index < guideFlow.count else {
            return
        }

        currentStep = guideFlow[index]
    }

    private func setupCameraForCalibration() {
        WLBonjourCameraListManager.shared.currentCamera?.enterDmsCameraCalibrationMode()
    }

    fileprivate func tearDown() {
        WLBonjourCameraListManager.shared.currentCamera?.exitDmsCameraCalibrationMode()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    @objc
    private func handleCurrentDeviceDidChangeNotification() {
        let messagePrefix = NSLocalizedString("Please connect camera (S/N)", comment: "Please connect camera (S/N)")

        func alert(camera sn: String) {
            if let alertVC = presenter.containerViewController?.topViewController?.topMostViewController as? UIAlertController, alertVC.message?.hasPrefix(messagePrefix) == true  {
                return
            }

            presenter.containerViewController?.topViewController?.alert(
                message: messagePrefix + ": " + sn,
                action1: { () -> UIAlertAction in
                    return UIAlertAction(title: NSLocalizedString("Cancel Calibration", comment: "Cancel Calibration"), style: .cancel) { [weak self] _ in
                        self?.presenter.comeToAnEnd()
                    }
            })
        }

        guard let initialCameraSN = initialCameraSN else {
            return
        }

        if let camera = WLBonjourCameraListManager.shared.currentCamera {
            if camera.sn != initialCameraSN {
                alert(camera: initialCameraSN)
            }
            else {
                if let alertVC = presenter.containerViewController?.topViewController?.topMostViewController as? UIAlertController, alertVC.message?.hasPrefix(messagePrefix) == true  {
                    alertVC.dismiss(animated: true, completion: nil)
                }
                setupCameraForCalibration()
            }
        }
        else {
            alert(camera: initialCameraSN)
        }
    }

}

class CalibrationGuidePresenter: NSObject, FlowGuidePresenter {
    typealias GuideType = CalibrationGuide
    typealias StepType = CalibrationGuideStep

    weak var flowGuide: CalibrationGuide? {
        didSet {
            containerViewController?.flowGuide = flowGuide
        }
    }

    fileprivate(set) weak var containerViewController: UINavigationController? // set to `weak` to avoid retain circle
    private weak var originalContainerViewControllerDelegate: UINavigationControllerDelegate? = nil
    private var stepViewControllersStack: [UIViewController]? = nil

    private lazy var cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .plain, target: self, action: #selector(cancelButtonTapped))

    init(containerViewController: UINavigationController? = nil) {
        super.init()

        if let containerViewController = containerViewController {
            originalContainerViewControllerDelegate = containerViewController.delegate
            containerViewController.delegate = self
            self.containerViewController = containerViewController
            stepViewControllersStack = []
        }
    }

    func present(_ step: CalibrationGuideStep, with params: [AnyHashable : Any]? = nil) {
        let stepVC = makeViewController(for: step, with: params)

        if stepViewControllersStack != nil {
            if stepViewControllersStack!.isEmpty { // the first step view controller
                stepVC.navigationItem.leftBarButtonItem = cancelButton
            }

            stepViewControllersStack!.append(stepVC)
        }

        if containerViewController == nil {
            let containerViewController = BaseNavigationController(rootViewController: stepVC)
            containerViewController.flowGuide = flowGuide
            containerViewController.delegate = self

            if #available(iOS 13.0, *) {
                containerViewController.modalPresentationStyle = .fullScreen
            }

            stepVC.navigationItem.leftBarButtonItem = cancelButton

            AppViewControllerManager.topViewController?.present(containerViewController, animated: true, completion: nil)

            self.containerViewController = containerViewController
        }
        else {
            if containerViewController?.viewControllers.first(where: {$0.classForCoder == stepVC.classForCoder}) != nil {
                containerViewController?.popToViewControllerWhichIsKind(of: stepVC.classForCoder, animated: true)
            }
            else {
                containerViewController?.pushViewController(stepVC, animated: true)
            }
        }
    }

    func makeViewController(for step: CalibrationGuideStep, with params: [AnyHashable : Any]?) -> UIViewController {
        let stepVC: UIViewController

        switch step {
        case .checkInstallationPosition:
            stepVC =  CalibrationInstallationPositionDependencyContainer().makeCalibrationInstallationPositionViewController()
        case .makeSureCameraOrientation:
            stepVC = CalibrationCameraOrientationDependencyContainer().makeCalibrationCameraOrientationViewController()
        case .inputVehicleInfo:
            stepVC = CalibrationVehicleInfoDependencyContainer().makeCalibrationVehicleInfoViewController()
        case .adjustCameraPosition:
            stepVC = CalibrationAdjustCameraPositionDependencyContainer().makeCalibrationAdjustCameraPositionViewController()
        case .calib:
            stepVC = CalibrationCalibrateDependencyContainer().makeCalibrationCalibrateViewController()
        }

        return stepVC
    }

    func dismiss() {
        flowGuide?.tearDown()
        containerViewController?.dismiss(animated: true, completion: nil)
    }

    func comeToAnEnd() {
        if let parent = flowGuide?.parent {
            flowGuide?.tearDown()
            containerViewController?.delegate = originalContainerViewControllerDelegate
            originalContainerViewControllerDelegate = nil
            containerViewController?.flowGuide = parent
            parent.nextStep()
        }
        else {
            dismiss()
        }
    }

    @objc
    private func cancelButtonTapped() {
        dismiss()
    }
}

extension CalibrationGuidePresenter: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.title = NSLocalizedString("Calibration", comment: "Calibration")
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if stepViewControllersStack != nil {
            while !stepViewControllersStack!.isEmpty && stepViewControllersStack?.last != viewController {
                _ = stepViewControllersStack?.popLast()
            }

            if stepViewControllersStack?.isEmpty == false {
                flowGuide?.updateCurrentStep(with: stepViewControllersStack!.count - 1)
            }
        }
        else {
            flowGuide?.updateCurrentStep(with: navigationController.viewControllers.count - 1)
        }
    }

}
