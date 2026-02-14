//
//  GeoFenceRuleDetailDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class GeoFenceRuleDetailDependencyContainer {

    let stateStore: ReSwift.Store<GeoFenceRuleDetailViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(rule: GeoFenceRule) {
        stateStore = ReSwift.Store(reducer: Reducers.GeoFenceRuleDetailReducer, state: GeoFenceRuleDetailViewControllerState(rule: rule))
    }

    func makeGeoFenceRuleDetailViewController() -> GeoFenceRuleDetailViewController {
        let stateObservable = makeGeoFenceRuleDetailViewControllerStateObservable()
        let observer = ObserverForGeoFenceRuleDetail(state: stateObservable)
        let userInterface = GeoFenceRuleDetailRootView()
        let viewController = GeoFenceRuleDetailViewController(
            observer: observer,
            userInterface: userInterface,
            viewControllerFactory: self,
            loadGeoFenceUseCaseFactory: self,
            loadGeoFenceRuleUseCaseFactory: self,
            removeGeoFenceRuleUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension GeoFenceRuleDetailDependencyContainer {

    func makeGeoFenceRuleDetailViewControllerStateObservable() -> Observable<GeoFenceRuleDetailViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension GeoFenceRuleDetailDependencyContainer: GeoFenceRuleDetailViewControllerFactory {

    func makeTriggeringVehicleListViewController() -> UIViewController {
        return TriggeringVehicleListDependencyContainer(rule: stateStore.state.rule!).makeTriggeringVehicleListViewController()
    }

    func makeGeoFenceRuleComposingViewController() -> UIViewController {
        let vc = AddNewGeoFenceDependencyContainer(
            rule: GeoFenceRuleForEdit(rule: stateStore.state.rule),
            fence:  stateStore.state.fence
        )
            .makeAddNewGeoFenceViewController()
            .embedInNavigationController()

        return vc
    }

}

//MARK: - Use Case

extension GeoFenceRuleDetailDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<GeoFenceRuleDetailFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension GeoFenceRuleDetailDependencyContainer: LoadGeoFenceUseCaseFactory {

    func makeLoadGeoFenceUseCase(geoFenceID: GeoFenceId?) -> UseCase {
        return LoadGeoFenceUseCase(geoFenceID: stateStore.state.rule!.fenceID, actionDispatcher: actionDispatcher)
    }

}

extension GeoFenceRuleDetailDependencyContainer: RemoveGeoFenceRuleUseCaseFactory {

    func makeRemoveGeoFenceRuleUseCase(completion: @escaping RemoveGeoFenceRuleUseCase.Completion) -> UseCase {
        return RemoveGeoFenceRuleUseCase(
            fenceRuleID: stateStore.state.rule!.fenceRuleID,
            fence: stateStore.state.fence,
            actionDispatcher: actionDispatcher,
            completion: completion
        )
    }

}

extension GeoFenceRuleDetailDependencyContainer: LoadGeoFenceRuleUseCaseFactory {

    func makeLoadGeoFenceRuleUseCase() -> UseCase {
        return LoadGeoFenceRuleUseCase(
            geoFenceRuleID: stateStore.state.rule!.fenceRuleID,
            actionDispatcher: actionDispatcher
        )
    }

}
