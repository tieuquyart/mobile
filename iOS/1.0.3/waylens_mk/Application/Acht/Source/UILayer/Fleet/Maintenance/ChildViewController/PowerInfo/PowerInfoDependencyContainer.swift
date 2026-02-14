//
//  PowerInfoDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift
import WaylensCameraSDK

class PowerInfoDependencyContainer {

    let stateStore: ReSwift.Store<PowerInfoViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.PowerInfoReducer, state: PowerInfoViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makePowerInfoViewController() -> PowerInfoViewController {
        let stateObservable = makePowerInfoViewControllerStateObservable()
        let stateObserver = ObserverForPowerInfo(state: stateObservable)
        let cameraObserver = ObserverForCurrentConnectedCamera()
        let cameraKeyPathObserver = KeyPathObserverForCurrentConnectedCamera(keyPathsToObserve: \WLCameraDevice.batteryInfo)
        let composedObservers =
            ObserverComposition(observers: stateObserver, cameraObserver, cameraKeyPathObserver)

        let userInterface = PowerInfoRootView()
        let viewController = PowerInfoViewController(
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

private extension PowerInfoDependencyContainer {

    func makePowerInfoViewControllerStateObservable() -> Observable<PowerInfoViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension PowerInfoDependencyContainer: PowerInfoViewControllerFactory {

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
        default:
            return viewControllerClass.init()
        }
    }

}

//MARK: - Use Case

extension PowerInfoDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<PowerInfoFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}

extension PowerInfoDependencyContainer: GeneralUseCaseFactory {

    func makeGeneralUseCase(value: Any) -> UseCase {
        return GeneralUseCase(value: value, actionDispatcher: actionDispatcher)
    }

}
