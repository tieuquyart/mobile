//
//  CameraTypeSelectionDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class CameraTypeSelectionDependencyContainer {

    let stateStore: ReSwift.Store<CameraTypeSelectionViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.CameraTypeSelectionReducer, state: CameraTypeSelectionViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    enum Scene {
        case installation
        case network
    }
    private(set) var scene: Scene

    init(scene: Scene) {
        self.scene = scene
    }

    func makeCameraTypeSelectionViewController() -> CameraTypeSelectionViewController {
        let stateObservable = makeCameraTypeSelectionViewControllerStateObservable()
        let observer = ObserverForCameraTypeSelection(state: stateObservable)
        let userInterface = CameraTypeSelectionRootView()
        let viewController = CameraTypeSelectionViewController(
            observer: observer,
            userInterface: userInterface,
            viewControllerFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController

        switch scene {
        case .installation:
            viewController.title = NSLocalizedString("Installation", comment: "Installation")
        default:
            viewController.title = NSLocalizedString("Network", comment: "Network")
        }
        return viewController
    }

}

//MARK: - Private

private extension CameraTypeSelectionDependencyContainer {

    func makeCameraTypeSelectionViewControllerStateObservable() -> Observable<CameraTypeSelectionViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension CameraTypeSelectionDependencyContainer: CameraTypeSelectionViewControllerFactory {

    func makeViewController(for cameraType: CameraType) -> UIViewController? {
        switch scene {
        case .installation:
            switch cameraType {
            case .secure360OrSecure4K:
                return nil
            case .secureES:
                return SecureEsNetworkMobilePhoneStepOneDependencyContainer().makeSecureEsNetworkMobilePhoneStepOneViewController().embedInNavigationController()
            }
        case .network:
            switch cameraType {
            case .secure360OrSecure4K:
                return NetworkDiagnosisViewController.createViewController()
            case .secureES:
                return SecureEsNetworkMobilePhoneStepOneDependencyContainer().makeSecureEsNetworkMobilePhoneStepOneViewController().embedInNavigationController()
            }
        }
    }

}

//MARK: - Use Case

extension CameraTypeSelectionDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<CameraTypeSelectionFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}
