//
//  MaintenanceViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class MaintenanceViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: MaintenanceUserInterfaceView
    private let viewControllerFactory: MaintenanceViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let generalUseCaseFactory: GeneralUseCaseFactory

    init(
        observer: Observer,
        userInterface: MaintenanceUserInterfaceView,
        viewControllerFactory: MaintenanceViewControllerFactory,
        generalUseCaseFactory: GeneralUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.generalUseCaseFactory = generalUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Maintenance", comment: "Maintenance")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userInterface
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        observer.startObserving()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension MaintenanceViewController {

}

extension MaintenanceViewController: MaintenanceIxResponder {

    func navigateTo(viewController: UIViewController.Type) {
        switch viewController {
        case _ as PCTCableTypeViewController.Type:
            _ = showPowerCordTestIfPossible()
        case _ as SafariViewController.Type:
            openBrowser(withURLString: "\(UserSetting.shared.webServer.rawValue)/support/faq/28/33?webview=1")
        case _ as UIAlertController.Type:
            if WLBonjourCameraListManager.shared.currentCamera != nil {
                showApnSetting()
            }
            else {
                alertCameraWiFiConnectionMessage()
            }
        case _ as CalibrationInstallationPositionViewController.Type:
            let currentCamera = UnifiedCamera(local: WLBonjourCameraListManager.shared.currentCamera, remote: nil)
            if currentCamera.featureAvailability.isDmsCameraCalibrationAvailable {
                CalibrationGuide(presenter: CalibrationGuidePresenter()).start()
            }
            else {
                alert(message: NSLocalizedString("firmware_out_of_date", comment: "Firmware out of date.\nPlease update your camera's firmware."))
            }
        default:
            let toVC = viewControllerFactory.makeViewController(with: viewController)
            navigationController?.pushViewController(toVC, animated: true)
        }
    }

    func logout() {
      //  presentLogOutConfirmation()
        appDelegate.setupRootViewController()
    }

    func login() {
        AppViewControllerManager.gotoLogin()
    }

}

extension MaintenanceViewController: ObserverForMaintenanceEventResponder {

    func received(newState: MaintenanceViewControllerState) {
        userInterface.render(newState: newState)
    }

    func received(newErrorMessage: ErrorMessage) {
        alert(title: newErrorMessage.title, message: newErrorMessage.message, action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { [weak self] (action) in
                self?.makeFinishedPresentingErrorUseCase(newErrorMessage).start()
            })
        })
    }
}

extension MaintenanceViewController: ObserverForCurrentConnectedCameraEventResponder {

    func connectedCameraDidChange(_ camera: WLCameraDevice?) {
        generalUseCaseFactory.makeGeneralUseCase(value: UnifiedCamera(local: camera, remote: nil)).start()
    }

}

extension MaintenanceViewController: KeyPathObserverForCurrentConnectedCameraEventResponder {

    func camera(_ camera: WLCameraDevice, attributeDidChange attributeKeyPath: PartialKeyPath<WLCameraDevice>) {
        generalUseCaseFactory.makeGeneralUseCase(value: UnifiedCamera(local: nil, remote: nil)).start()
        generalUseCaseFactory.makeGeneralUseCase(value: UnifiedCamera(local: camera, remote: nil)).start()
    }

}

protocol MaintenanceViewControllerFactory {
    func makeViewController(with viewControllerClass: UIViewController.Type) -> UIViewController
}
