//
//  SecureEsNetworkMobilePhoneStepOneDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class SecureEsNetworkMobilePhoneStepOneDependencyContainer {

    let stateStore: ReSwift.Store<SecureEsNetworkMobilePhoneStepOneViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.SecureEsNetworkMobilePhoneStepOneReducer, state: SecureEsNetworkMobilePhoneStepOneViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeSecureEsNetworkMobilePhoneStepOneViewController() -> SecureEsNetworkMobilePhoneStepOneViewController {
        let stateObservable = makeSecureEsNetworkMobilePhoneStepOneViewControllerStateObservable()
        let observer = ObserverForSecureEsNetworkMobilePhoneStepOne(state: stateObservable)
        let userInterface = SecureEsNetworkMobilePhoneStepOneRootView()
        let viewController = SecureEsNetworkMobilePhoneStepOneViewController(
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

private extension SecureEsNetworkMobilePhoneStepOneDependencyContainer {

    func makeSecureEsNetworkMobilePhoneStepOneViewControllerStateObservable() -> Observable<SecureEsNetworkMobilePhoneStepOneViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension SecureEsNetworkMobilePhoneStepOneDependencyContainer: SecureEsNetworkMobilePhoneStepOneViewControllerFactory {

    func makeViewControllerForNextStep() -> UIViewController {
        return SecureEsNetworkMobilePhoneStepTwoDependencyContainer().makeSecureEsNetworkMobilePhoneStepTwoViewController()
    }

}

//MARK: - Use Case

extension SecureEsNetworkMobilePhoneStepOneDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<SecureEsNetworkMobilePhoneStepOneFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}
