//
//  TriggeringVehicleListDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class TriggeringVehicleListDependencyContainer {

    let stateStore: ReSwift.Store<TriggeringVehicleListViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(rule: GeoFenceRule) {
        stateStore = ReSwift.Store(
            reducer: Reducers.TriggeringVehicleListReducer,
            state: TriggeringVehicleListViewControllerState(rule: GeoFenceRuleForEdit(rule: rule))
        )
    }

    func makeTriggeringVehicleListViewController() -> TriggeringVehicleListViewController {
        let stateObservable = makeTriggeringVehicleListViewControllerStateObservable()
        let observer = ObserverForTriggeringVehicleList(state: stateObservable)
        let userInterface = TriggeringVehicleListRootView()
        let viewController = TriggeringVehicleListViewController(
            observer: observer,
            userInterface: userInterface,
            viewControllerFactory: self,
            loadVehicleListUseCaseFactory: self,
            loadGeoFenceRuleUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension TriggeringVehicleListDependencyContainer {

    func makeTriggeringVehicleListViewControllerStateObservable() -> Observable<TriggeringVehicleListViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension TriggeringVehicleListDependencyContainer: TriggeringVehicleListViewControllerFactory {

    func makeViewControllerForEdit() -> UIViewController {
        let vc = GeoFenceRuleTypeAndScopeDependencyContainer(
            rule: stateStore.state.rule,
            enableTypeChoices: false
        ).makeGeoFenceRuleTypeAndScopeViewController()
        return vc
    }

}

//MARK: - Use Case

extension TriggeringVehicleListDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<TriggeringVehicleListFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension TriggeringVehicleListDependencyContainer: LoadVehicleListUseCaseFactory {

    func makeLoadVehicleListUseCase() -> UseCase {
        return LoadVehicleListUseCase(actionDispatcher: actionDispatcher)
    }

}

extension TriggeringVehicleListDependencyContainer: LoadGeoFenceRuleUseCaseFactory {

    func makeLoadGeoFenceRuleUseCase() -> UseCase {
        return LoadGeoFenceRuleUseCase(
            geoFenceRuleID: stateStore.state.rule.fenceRuleID!,
            actionDispatcher: actionDispatcher
        )
    }

}
