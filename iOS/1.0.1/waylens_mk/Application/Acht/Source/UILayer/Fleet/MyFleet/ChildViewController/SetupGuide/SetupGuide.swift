//
//  SetupGuide.swift
//  Fleet
//
//  Created by forkon on 2019/11/25.
//  Copyright © 2019 waylens. All rights reserved.
//

import WaylensCameraSDK

public enum SetupStep: FlowGuideStep, Equatable {
    case setupVehicleAndCamera
    case connectCameraWifiAndDetectViewMode
    case detectPowerCord
    case activateCamera
    case checkCameraNetwork
    case calibrateDmsCamera
    case showSuccess
}

public enum SetupGuideScene {
    case vehicleSetup
    case installerGuide
    case cameraTour

    public var guideFlow: [SetupStep] {
        switch self {
        case .vehicleSetup:
            return [
                .setupVehicleAndCamera,
                .connectCameraWifiAndDetectViewMode,
                .detectPowerCord,
                .activateCamera,
                .checkCameraNetwork,
                .calibrateDmsCamera,
                .showSuccess
            ]
        case .cameraTour:
            return [
                .connectCameraWifiAndDetectViewMode,
                .detectPowerCord,
                .activateCamera,
                .checkCameraNetwork,
                .calibrateDmsCamera,
                .showSuccess
            ]
        case .installerGuide:
            return [
                .connectCameraWifiAndDetectViewMode,
                .detectPowerCord,
                .checkCameraNetwork,
                .calibrateDmsCamera,
                .showSuccess
            ]
        }
    }
}

public class SetupGuide: NSObject, FlowGuide {
    public var vehicle: VehicleProfile = VehicleProfile.emptyProfile
    public var driver: FleetMember? = nil
    public var camera: CameraProfile? = nil

    public let scene: SetupGuideScene

    private let guideFlow: [SetupStep]
    private let presenter: SetupGuidePresenter

    public private(set) var currentStep: SetupStep?

    public init(scene: SetupGuideScene, presenter: SetupGuidePresenter) {
        self.scene = scene
        self.guideFlow = scene.guideFlow
        self.presenter = presenter

        super.init()

        self.presenter.flowGuide = self
    }

    public func start() {
        currentStep = guideFlow.first

        if let currentStep = currentStep {
            presenter.present(currentStep, with: nil)
        }
    }

    public func nextStep() {
        nextStep(with: nil)
    }

    public func nextStep(with params: [AnyHashable : Any]?) {
        var next: SetupStep?

        if let index = guideFlow.firstIndex(of: currentStep!), index + 1 < guideFlow.count {
            next = guideFlow[index + 1]

            if next == .calibrateDmsCamera {
                let currentCamera = UnifiedCamera(local: WLBonjourCameraListManager.shared.currentCamera, remote: nil)
                if (currentCamera.local?.hasDmsCamera == true) && (currentCamera.featureAvailability.isDmsCameraCalibrationAvailable) {
                    let calibGuide = CalibrationGuide(presenter: CalibrationGuidePresenter(containerViewController: presenter.containerViewController))
                    calibGuide.parent = self
                    calibGuide.start()
                }
                else {
                    currentStep = next
                    nextStep()
                    return
                }
            }
            else {
                if camera?.isActive == true && next == .activateCamera {
                    currentStep = next
                    nextStep()
                    return
                }

                presenter.present(next!, with: params)
            }
        } else {
            // done, quit
            presenter.dismiss()
        }

        currentStep = next
    }

}

public class SetupGuidePresenter: FlowGuidePresenter {
    public typealias GuideType = SetupGuide
    public typealias StepType = SetupStep

    open weak var flowGuide: SetupGuide?

    fileprivate weak var containerViewController: UINavigationController?

    open func present(_ step: SetupStep, with params: [AnyHashable : Any]?) {

    }

    open func makeViewController(for step: SetupStep, with params: [AnyHashable : Any]?) -> UIViewController {
        return UIViewController()
    }

    open func dismiss() {

    }
}

class VehicleSetupGuidePresenter: SetupGuidePresenter {
    private lazy var quitButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .plain, target: self, action: #selector(quitButtonTapped(_:)))

    override func present(_ step: SetupStep, with params: [AnyHashable : Any]? = nil) {
        let stepVC = makeViewController(for: step, with: params)

        if containerViewController == nil {
            let containerViewController = BaseNavigationController(rootViewController: stepVC)
            containerViewController.flowGuide = flowGuide

            if #available(iOS 13.0, *) {
                containerViewController.modalPresentationStyle = .fullScreen
            }
            
            AppViewControllerManager.topViewController?.present(containerViewController, animated: true, completion: nil)
            self.containerViewController = containerViewController
        }
        else {
            containerViewController?.setViewControllers([stepVC], animated: true)
        }
    }

    override func makeViewController(for step: SetupStep, with params: [AnyHashable : Any]? = nil) -> UIViewController {
        guard let flowGuide = flowGuide else {
            fatalError()
        }

        let stepVC: UIViewController

        switch step {
        case .setupVehicleAndCamera:
            stepVC = SetupVehicleDependencyContainer().makeSetupVehicleViewController()
        case .connectCameraWifiAndDetectViewMode:
            stepVC = SetupStepOneViewController.createViewController()
        case .detectPowerCord:
            let camera = UnifiedCameraManager.shared.local

            if camera?.featureAvailability.isUntrustACCWireSupportAvailable == true {
                stepVC = PCTCableTypeViewController.createViewController()
                (stepVC as? PCTCableTypeViewController)?.camera = camera
            } else {
                stepVC = WireDiagnosisPrepareViewController.createViewController()
                (stepVC as? WireDiagnosisPrepareViewController)?.camera = camera
            }
        case .activateCamera:
            stepVC = ActivateCameraDependencyContainer(camera: flowGuide.camera!).makeActivateCameraViewController()
        case .checkCameraNetwork:
            stepVC = NetworkDiagnosisViewController.createViewController()
            (stepVC as? NetworkDiagnosisViewController)?.camera = UnifiedCameraManager.shared.local
        case .showSuccess:
            stepVC = SetupSuccessDependencyContainer(vehicle: flowGuide.vehicle, driver: flowGuide.driver, camera: flowGuide.camera).makeSetupSuccessViewController()
        case .calibrateDmsCamera:
            stepVC = UIViewController()
        }

        if step != .showSuccess {
            stepVC.navigationItem.leftBarButtonItem = quitButton
        }

        return stepVC
    }

    override func dismiss() {
        containerViewController?.dismissMyself(animated: true)
    }

    @objc func quitButtonTapped(_ sender: Any) {
        dismiss()
    }

}

class InstallerSetupGuidePresenter: SetupGuidePresenter {
    typealias GuideType = SetupGuide
    typealias StepType = SetupStep

    override weak var flowGuide: SetupGuide? {
        didSet {
            containerViewController?.flowGuide = flowGuide
        }
    }

    private lazy var quitButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .plain, target: self, action: #selector(quitButtonTapped(_:)))

    override func present(_ step: SetupStep, with params: [AnyHashable : Any]? = nil) {
        let stepVC = makeViewController(for: step, with: params)

        if containerViewController == nil {
            let containerViewController = BaseNavigationController(rootViewController: stepVC)
            containerViewController.flowGuide = flowGuide

            if #available(iOS 13.0, *) {
                containerViewController.modalPresentationStyle = .fullScreen
            }

            AppViewControllerManager.topViewController?.present(containerViewController, animated: true, completion: nil)
            self.containerViewController = containerViewController
        }
        else {
            containerViewController?.setViewControllers([stepVC], animated: true)
        }
    }

    override func makeViewController(for step: SetupStep, with params: [AnyHashable : Any]? = nil) -> UIViewController {
        guard let flowGuide = flowGuide else {
            fatalError()
        }

        let stepVC: UIViewController

        switch step {
        case .setupVehicleAndCamera:
            stepVC = SetupVehicleDependencyContainer().makeSetupVehicleViewController()
        case .connectCameraWifiAndDetectViewMode:
            stepVC = SetupStepOneViewController.createViewController()
        case .detectPowerCord:
            let camera = UnifiedCameraManager.shared.local

            if camera?.featureAvailability.isUntrustACCWireSupportAvailable == true {
                stepVC = PCTCableTypeViewController.createViewController()
                (stepVC as? PCTCableTypeViewController)?.camera = camera
            } else {
                stepVC = WireDiagnosisPrepareViewController.createViewController()
                (stepVC as? WireDiagnosisPrepareViewController)?.camera = camera
            }
        case .activateCamera:
            stepVC = ActivateCameraDependencyContainer(camera: flowGuide.camera!).makeActivateCameraViewController()
        case .checkCameraNetwork:
            stepVC = NetworkDiagnosisViewController.createViewController()
            (stepVC as? NetworkDiagnosisViewController)?.camera = UnifiedCameraManager.shared.local
        case .showSuccess:
            if (params?["networkDiagnosisFailed"] as? Bool) == true  {
                let config = FinishViewControllerConfig(
                    icon: #imageLiteral(resourceName: "icon_sign_warning"),
                    title: NSLocalizedString("Almost Finished", comment: "Almost Finished"),
                    subtitle: NSLocalizedString("Please contact the supplier for the cause of the network error.", comment: "Please contact the supplier for the cause of the network error."),
                    buttonTitle: NSLocalizedString("OK", comment: "OK")
                ) { viewController in
                    viewController?.parent?.flowGuide?.nextStep()
                    AppViewControllerManager.gotoCameraTab()
                }

                let vc = FinishViewController(config: config)
                vc.title = NSLocalizedString("Installation", comment: "Installation")

                stepVC = vc
            }
            else {
                var config = FinishViewControllerConfig.finish
                config.subtitle = NSLocalizedString("The camera installed successfully.", comment: "The camera installed successfully.")
                config.buttonAction = { viewController in
                    viewController?.parent?.flowGuide?.nextStep()
                    AppViewControllerManager.gotoCameraTab()
                }

                let vc = FinishViewController(config: config)
                vc.title = NSLocalizedString("Installation", comment: "Installation")

                stepVC = vc
            }
        case .calibrateDmsCamera:
            stepVC = UIViewController()
        }

        if step != .showSuccess {
            stepVC.navigationItem.leftBarButtonItem = quitButton
        }

        return stepVC
    }

    override func dismiss() {
        containerViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func quitButtonTapped(_ sender: Any) {
        dismiss()
    }

}

class CameraTourSetupGuidePresenter: SetupGuidePresenter {
    private lazy var quitButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .plain, target: self, action: #selector(quitButtonTapped(_:)))

    override func present(_ step: SetupStep, with params: [AnyHashable : Any]? = nil) {
        let stepVC = makeViewController(for: step, with: params)

        if containerViewController == nil {
            let containerViewController = BaseNavigationController(rootViewController: stepVC)
            containerViewController.flowGuide = flowGuide

            if #available(iOS 13.0, *) {
                containerViewController.modalPresentationStyle = .fullScreen
            }

            AppViewControllerManager.topViewController?.present(containerViewController, animated: true, completion: nil)
            self.containerViewController = containerViewController
        }
        else {
            containerViewController?.setViewControllers([stepVC], animated: true)
        }
    }

    override func makeViewController(for step: SetupStep, with params: [AnyHashable : Any]? = nil) -> UIViewController {
        guard let flowGuide = flowGuide else {
            fatalError()
        }

        let stepVC: UIViewController

        switch step {
        case .setupVehicleAndCamera:
            fatalError("No this step.")
        case .connectCameraWifiAndDetectViewMode:
            stepVC = SetupStepOneViewController.createViewController()
        case .detectPowerCord:
            let camera = UnifiedCameraManager.shared.local

            if camera?.featureAvailability.isUntrustACCWireSupportAvailable == true {
                stepVC = PCTCableTypeViewController.createViewController()
                (stepVC as? PCTCableTypeViewController)?.camera = camera
            } else {
                stepVC = WireDiagnosisPrepareViewController.createViewController()
                (stepVC as? WireDiagnosisPrepareViewController)?.camera = camera
            }
        case .activateCamera:
            stepVC = ActivateCameraDependencyContainer(camera: flowGuide.camera!).makeActivateCameraViewController()
        case .checkCameraNetwork:
            stepVC = NetworkDiagnosisViewController.createViewController()
            (stepVC as? NetworkDiagnosisViewController)?.camera = UnifiedCameraManager.shared.local
        case .calibrateDmsCamera:
            fatalError("Has handled this step in other place.")
        case .showSuccess:
            var config = FinishViewControllerConfig.finish
            config.subtitle = NSLocalizedString("The camera installed successfully.", comment: "The camera installed successfully.")
            config.buttonAction = { viewController in
                viewController?.parent?.flowGuide?.nextStep()
            }

            let vc = FinishViewController(config: config)
            vc.title = NSLocalizedString("Installation", comment: "Installation")

            stepVC = vc
        }

        if step != .showSuccess {
            stepVC.navigationItem.leftBarButtonItem = quitButton
        }

        return stepVC
    }

    override func dismiss() {
        containerViewController?.dismissMyself(animated: true)
    }

    @objc func quitButtonTapped(_ sender: Any) {
        dismiss()
    }

}
