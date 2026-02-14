//
//  MyFleetViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class MyFleetViewController: BaseViewController {
    
    private let observer: Observer
    private let userInterface: MyFleetUserInterfaceView
    private let reloadUserProfileUseCaseFactory: ReloadUserProfileUseCaseFactory
    private let viewControllerFactory: MyFleetViewControllerFactory

    init(
        observer: Observer,
        userInterface: MyFleetUserInterfaceView,
        reloadUserProfileUseCaseFactory: ReloadUserProfileUseCaseFactory,
        viewControllerFactory: MyFleetViewControllerFactory
        ) {
        self.observer = observer
        self.userInterface = userInterface
        self.reloadUserProfileUseCaseFactory = reloadUserProfileUseCaseFactory
        self.viewControllerFactory = viewControllerFactory

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userInterface
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("My Fleet", comment: "My Fleet")

        observer.startObserving()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let reloadUserProfileUseCase = reloadUserProfileUseCaseFactory.makeReloadUserProfileUseCase()
        reloadUserProfileUseCase.start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }

}

extension MyFleetViewController: MyFleetIxResponder {

    func navigateTo(viewController: UIViewController.Type) {
        switch viewController {
        case _ as SetupVehicleViewController.Type:
            SetupGuide(
                scene: .vehicleSetup,
                presenter: VehicleSetupGuidePresenter()
            ).start()
        case _ as SafariViewController.Type:
            openBrowser(withURLString: UserSetting.shared.webServer.shopUrl)
        case _ as SetupStepOneViewController.Type:
            let vc = AppViewControllerManager.createTabBarControllerCamera()
            appDelegate.setRootVC(vc: vc)
        case _ as GetLogViewController.Type:
            let vc = GetLogViewController(nibName: "GetLogViewController", bundle: nil)
            vc.camera = UnifiedCameraManager.shared.local
            navigationController?.pushViewController(vc, animated: true)
            
        case _ as SimDataViewController.Type:
            let vc = SimDataViewController(nibName: "SimDataViewController", bundle: nil)
            vc.camera = UnifiedCameraManager.shared.local
            navigationController?.pushViewController(vc, animated: true)
            
        case _ as LoginFaceViewController.Type:
            
            let vc =  LoginFaceDependencyContainer().makeLoginFaceViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            let toVC = viewControllerFactory.makeViewController(with: viewController)
            navigationController?.pushViewController(toVC, animated: true)
        }
    }

}

extension MyFleetViewController: ObserverForMyFleetEventResponder {

    func received(newUserProfile userProfile: UserProfile) {
        userInterface.render(userProfile: userProfile)
    }

}

extension MyFleetViewController: ObserverForCurrentConnectedCameraEventResponder {

    func connectedCameraDidChange(_ camera: WLCameraDevice?) {
        userInterface.render(newCameraConnected: camera)
        if
            camera == nil,
            let navigationController = navigationController,
            navigationController.viewControllers.count >= 2,
            navigationController.viewControllers[1] is HNCameraDetailViewController
        {
            AppViewControllerManager.dismissToRootViewController()
        }
    }

}

protocol MyFleetViewControllerFactory {
    func makeViewController(with viewControllerClass: UIViewController.Type) -> UIViewController
}
