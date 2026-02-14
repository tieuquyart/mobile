//
//  SecureEsNetworkMobilePhoneStepThreeDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class SecureEsNetworkMobilePhoneStepThreeDependencyContainer {

    let stateStore: ReSwift.Store<SecureEsNetworkMobilePhoneStepThreeViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.SecureEsNetworkMobilePhoneStepThreeReducer, state: SecureEsNetworkMobilePhoneStepThreeViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeSecureEsNetworkMobilePhoneStepThreeViewController() -> SecureEsNetworkMobilePhoneStepThreeViewController {
        let stateObservable = makeSecureEsNetworkMobilePhoneStepThreeViewControllerStateObservable()
        let observer = ObserverForSecureEsNetworkMobilePhoneStepThree(state: stateObservable)
        let userInterface = SecureEsNetworkMobilePhoneStepThreeRootView()
        let viewController = SecureEsNetworkMobilePhoneStepThreeViewController(
            observer: observer,
            userInterface: userInterface,
            viewControllerFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension SecureEsNetworkMobilePhoneStepThreeDependencyContainer {

    func makeSecureEsNetworkMobilePhoneStepThreeViewControllerStateObservable() -> Observable<SecureEsNetworkMobilePhoneStepThreeViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension SecureEsNetworkMobilePhoneStepThreeDependencyContainer: SecureEsNetworkMobilePhoneStepThreeViewControllerFactory {


}

//MARK: - Use Case

extension SecureEsNetworkMobilePhoneStepThreeDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<SecureEsNetworkMobilePhoneStepThreeFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}
