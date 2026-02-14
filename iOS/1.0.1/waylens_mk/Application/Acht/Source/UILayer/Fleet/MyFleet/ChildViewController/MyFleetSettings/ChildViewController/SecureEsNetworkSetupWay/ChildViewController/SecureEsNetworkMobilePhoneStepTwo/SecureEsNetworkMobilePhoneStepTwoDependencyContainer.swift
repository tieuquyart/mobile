//
//  SecureEsNetworkMobilePhoneStepTwoDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift
import WaylensCameraSDK

class SecureEsNetworkMobilePhoneStepTwoDependencyContainer {

    let stateStore: ReSwift.Store<SecureEsNetworkMobilePhoneStepTwoViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.SecureEsNetworkMobilePhoneStepTwoReducer, state: SecureEsNetworkMobilePhoneStepTwoViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeSecureEsNetworkMobilePhoneStepTwoViewController() -> SecureEsNetworkMobilePhoneStepTwoViewController {
        let stateObservable = makeSecureEsNetworkMobilePhoneStepTwoViewControllerStateObservable()
        let observer = ObserverForSecureEsNetworkMobilePhoneStepTwo(state: stateObservable)
        let userInterface = SecureEsNetworkMobilePhoneStepTwoRootView()
        let viewController = SecureEsNetworkMobilePhoneStepTwoViewController(
            observer: observer,
            userInterface: userInterface,
            addSsidToCameraUseCaseFactory: self,
            viewControllerFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension SecureEsNetworkMobilePhoneStepTwoDependencyContainer {

    func makeSecureEsNetworkMobilePhoneStepTwoViewControllerStateObservable() -> Observable<SecureEsNetworkMobilePhoneStepTwoViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension SecureEsNetworkMobilePhoneStepTwoDependencyContainer: SecureEsNetworkMobilePhoneStepTwoViewControllerFactory {

    func makeViewControllerForNextStep() -> UIViewController {
        return SecureEsNetworkMobilePhoneStepThreeDependencyContainer().makeSecureEsNetworkMobilePhoneStepThreeViewController()
    }
}

//MARK: - Use Case

extension SecureEsNetworkMobilePhoneStepTwoDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<SecureEsNetworkMobilePhoneStepTwoFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}

extension SecureEsNetworkMobilePhoneStepTwoDependencyContainer: AddSsidToCameraUseCaseFactory {

    func makeAddSsidToCameraUseCase(ssid: String, password: String) -> UseCase {
        return AddSsidToCameraUseCase(
            camera: WLBonjourCameraListManager.shared.currentCamera,
            ssid: ssid,
            password: password,
            actionDispatcher: actionDispatcher
        )
    }

}
