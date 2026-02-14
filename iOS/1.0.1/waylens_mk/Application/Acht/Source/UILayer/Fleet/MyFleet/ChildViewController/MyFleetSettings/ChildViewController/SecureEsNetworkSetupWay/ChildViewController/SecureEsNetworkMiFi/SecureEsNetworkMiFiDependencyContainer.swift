//
//  SecureEsNetworkMiFiDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class SecureEsNetworkMiFiDependencyContainer {

    let stateStore: ReSwift.Store<SecureEsNetworkMiFiViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.SecureEsNetworkMiFiReducer, state: SecureEsNetworkMiFiViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeSecureEsNetworkMiFiViewController() -> SecureEsNetworkMiFiViewController {
        let stateObservable = makeSecureEsNetworkMiFiViewControllerStateObservable()
        let observer = ObserverForSecureEsNetworkMiFi(state: stateObservable)
        let userInterface = SecureEsNetworkMiFiRootView()
        let viewController = SecureEsNetworkMiFiViewController(
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

private extension SecureEsNetworkMiFiDependencyContainer {

    func makeSecureEsNetworkMiFiViewControllerStateObservable() -> Observable<SecureEsNetworkMiFiViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension SecureEsNetworkMiFiDependencyContainer: SecureEsNetworkMiFiViewControllerFactory {


}

//MARK: - Use Case

extension SecureEsNetworkMiFiDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<SecureEsNetworkMiFiFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}
