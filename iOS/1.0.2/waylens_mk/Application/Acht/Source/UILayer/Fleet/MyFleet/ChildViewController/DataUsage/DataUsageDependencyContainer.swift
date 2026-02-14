//
//  DataUsageDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class DataUsageDependencyContainer {

    let stateStore: ReSwift.Store<DataUsageViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.DataUsageReducer, state: DataUsageViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeDataUsageViewController() -> DataUsageViewController {
        let stateObservable = makeDataUsageViewControllerStateObservable()
        let observer = ObserverForDataUsage(state: stateObservable)
        let userInterface = DataUsageRootView()
        let viewController = DataUsageViewController(
            observer: observer,
            userInterface: userInterface,
            dataUsageViewControllerFactory: self,
            fetchBillingDataUseCaseFactory: self,
            fetchHistoricalBillingDataUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension DataUsageDependencyContainer {

    func makeDataUsageViewControllerStateObservable() -> Observable<DataUsageViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension DataUsageDependencyContainer: DataUsageViewControllerFactory {

    func makeBillingDetailViewController(billingData: BillingData) -> UIViewController {
        return BillingDetailDependencyContainer(billingData: billingData).makeBillingDetailViewController()
    }

}

//MARK: - Use Case

extension DataUsageDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<DataUsageFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension DataUsageDependencyContainer: FetchBillingDataUseCaseFactory {

    func makeFetchBillingDataUseCase() -> UseCase {
        return FetchBillingDataUseCase(actionDispatcher: actionDispatcher)
    }
    
}

extension DataUsageDependencyContainer: FetchHistoricalBillingDataUseCaseFactory {

    func makeFetchHistoricalBillingDataUseCase() -> UseCase {
        return FetchHistoricalBillingDataUseCase(actionDispatcher: actionDispatcher)
    }

}
