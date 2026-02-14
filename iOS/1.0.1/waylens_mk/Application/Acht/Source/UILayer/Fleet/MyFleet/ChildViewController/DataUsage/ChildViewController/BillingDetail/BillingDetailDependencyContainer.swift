//
//  BillingDetailDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class BillingDetailDependencyContainer {

    let stateStore: ReSwift.Store<BillingDetailViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(billingData: BillingData) {
        self.stateStore = ReSwift.Store(reducer: Reducers.BillingDetailReducer, state: BillingDetailViewControllerState(billingData: billingData))
    }

    func makeBillingDetailViewController() -> BillingDetailViewController {
        let stateObservable = makeBillingDetailViewControllerStateObservable()
        let observer = ObserverForBillingDetail(state: stateObservable)
        let userInterface = BillingDetailRootView()
        let viewController = BillingDetailViewController(
            observer: observer,
            userInterface: userInterface,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension BillingDetailDependencyContainer {

    func makeBillingDetailViewControllerStateObservable() -> Observable<BillingDetailViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension BillingDetailDependencyContainer: BillingDetailViewControllerFactory {


}

//MARK: - Use Case

extension BillingDetailDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<BillingDetailFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension BillingDetailDependencyContainer: FetchBillingDataUseCaseFactory {

    func makeFetchBillingDataUseCase() -> UseCase {
        return FetchBillingDataUseCase(actionDispatcher: actionDispatcher)
    }
    
}

extension BillingDetailDependencyContainer: LoadCameraListUseCaseFactory {

    func makeLoadCameraListUseCase() -> UseCase {
        return LoadCameraListUseCase(actionDispatcher: actionDispatcher)
    }

}
