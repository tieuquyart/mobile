//
//  MaintenanceDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift
import WaylensCameraSDK

class MaintenanceDependencyContainer {

    let stateStore: ReSwift.Store<MaintenanceViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.MaintenanceReducer, state: MaintenanceViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeMaintenanceViewController() -> MaintenanceViewController {
        let stateObservable = makeMaintenanceViewControllerStateObservable()
        let stateObserver = ObserverForMaintenance(state: stateObservable)
        let cameraObserver = ObserverForCurrentConnectedCamera()
        let cameraKeyPathObserver = KeyPathObserverForCurrentConnectedCamera(keyPathsToObserve: \WLCameraDevice.hasDmsCamera, \WLCameraDevice.obdWorkModeConfig, \WLCameraDevice.adasConfig)
        let composedObservers =
            ObserverComposition(observers: stateObserver, cameraObserver, cameraKeyPathObserver)

        let userInterface = MaintenanceRootView()
        let viewController = MaintenanceViewController(
            observer: composedObservers,
            userInterface: userInterface,
            viewControllerFactory: self,
            generalUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        stateObserver.eventResponder = viewController
        cameraObserver.eventResponder = viewController
        cameraKeyPathObserver.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension MaintenanceDependencyContainer {

    func makeMaintenanceViewControllerStateObservable() -> Observable<MaintenanceViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension MaintenanceDependencyContainer: MaintenanceViewControllerFactory {

    func makeViewController(with viewControllerClass: UIViewController.Type) -> UIViewController {
        switch viewControllerClass {
        case _ as NetworkDiagnosisViewController.Type:
            return CameraTypeSelectionDependencyContainer(scene: .network).makeCameraTypeSelectionViewController()
        case _ as HNCSSDCardViewController.Type:
            let vc = HNCSSDCardViewController.createViewController()
            vc.camera = UnifiedCameraManager.shared.local
            return vc
        case _ as FeedbackController.Type:
            return FeedbackController.createViewController()
        case _ as PowerInfoViewController.Type:
            return PowerInfoDependencyContainer().makePowerInfoViewController()
        case _ as ObdWorkModeViewController.Type:
            return ObdWorkModeDependencyContainer().makeObdWorkModeViewController()
        case _ as AdasConfigViewController.Type:
            return AdasConfigDependencyContainer().makeAdasConfigViewController()
        case _ as AboutViewController.Type:
            return UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: String(describing: AboutViewController.self))
        case _ as DebugOptionViewController.Type:
            return UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: String(describing: DebugOptionViewController.self))
        default:
            return viewControllerClass.init()
        }
    }

}

//MARK: - Use Case

extension MaintenanceDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<MaintenanceFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}

extension MaintenanceDependencyContainer: GeneralUseCaseFactory {

    func makeGeneralUseCase(value: Any) -> UseCase {
        return GeneralUseCase(value: value, actionDispatcher: actionDispatcher)
    }

}
