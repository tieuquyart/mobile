//
//  SecureEsNetworkSetupWayDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class SecureEsNetworkSetupWayDependencyContainer {

    let stateStore: ReSwift.Store<SecureEsNetworkSetupWayViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.SecureEsNetworkSetupWayReducer, state: SecureEsNetworkSetupWayViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeSecureEsNetworkSetupWayViewController() -> SecureEsNetworkSetupWayViewController {
        let stateObservable = makeSecureEsNetworkSetupWayViewControllerStateObservable()
        let observer = ObserverForSecureEsNetworkSetupWay(state: stateObservable)
        let userInterface = SecureEsNetworkSetupWayRootView()
        let viewController = SecureEsNetworkSetupWayViewController(
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

private extension SecureEsNetworkSetupWayDependencyContainer {

    func makeSecureEsNetworkSetupWayViewControllerStateObservable() -> Observable<SecureEsNetworkSetupWayViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension SecureEsNetworkSetupWayDependencyContainer: SecureEsNetworkSetupWayViewControllerFactory {

    func makeViewController(for setupWay: SecureEsNetworkSetupWay) -> UIViewController {
        switch setupWay {
        case .throughMiFiHotspot:
            return SecureEsNetworkMiFiDependencyContainer().makeSecureEsNetworkMiFiViewController()
        case .throughMobilePhoneHotspot:
            return SecureEsNetworkMobilePhoneStepOneDependencyContainer().makeSecureEsNetworkMobilePhoneStepOneViewController()
        }
    }

}

//MARK: - Use Case

extension SecureEsNetworkSetupWayDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<SecureEsNetworkSetupWayFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}
