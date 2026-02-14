//
//  GeoFenceRuleTypeAndScopeDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class GeoFenceRuleTypeAndScopeDependencyContainer {

    let stateStore: ReSwift.Store<GeoFenceRuleTypeAndScopeViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(rule: GeoFenceRuleForEdit, enableTypeChoices: Bool) {
        stateStore = ReSwift.Store(
            reducer: Reducers.GeoFenceRuleTypeAndScopeReducer,
            state: GeoFenceRuleTypeAndScopeViewControllerState(
                rule: rule,
                enableTypeChoices: enableTypeChoices
            )
        )
    }

    func makeGeoFenceRuleTypeAndScopeViewController() -> GeoFenceRuleTypeAndScopeViewController {
        let stateObservable = makeGeoFenceRuleTypeAndScopeViewControllerStateObservable()
        let observer = ObserverForGeoFenceRuleTypeAndScope(state: stateObservable)
        let userInterface = GeoFenceRuleTypeAndScopeRootView()
        let viewController = GeoFenceRuleTypeAndScopeViewController(
            observer: observer,
            userInterface: userInterface,
            viewControllerFactory: self,
            editGeoFenceRuleUseCaseFactory: self,
            selectorSelectUseCaseFactory: self,
            saveGeoFenceRuleUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension GeoFenceRuleTypeAndScopeDependencyContainer {

    func makeGeoFenceRuleTypeAndScopeViewControllerStateObservable() -> Observable<GeoFenceRuleTypeAndScopeViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension GeoFenceRuleTypeAndScopeDependencyContainer: GeoFenceRuleTypeAndScopeViewControllerFactory {

    func makeViewControllerForNextStep() -> UIViewController {
        let vc = TriggeringVehicleSelectorDependencyContainer(rule: stateStore.state.rule).makeTriggeringVehicleSelectorViewController()
        return vc
    }

}

//MARK: - Use Case

extension GeoFenceRuleTypeAndScopeDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<GeoFenceRuleTypeAndScopeFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension GeoFenceRuleTypeAndScopeDependencyContainer: EditGeoFenceRuleUseCaseFactory {

    func makeEditGeoFenceRuleUseCase(_ reducer: @escaping (inout GeoFenceRuleForEdit) -> ()) -> UseCase {
        return EditGeoFenceRuleUseCase(rule: stateStore.state.rule, reducer: reducer, actionDispatcher: actionDispatcher)
    }

}

extension GeoFenceRuleTypeAndScopeDependencyContainer: SelectorSelectUseCaseFactory {

    func makeSelectorSelectUseCase(indexPath: IndexPath) -> UseCase {
        return SelectorSelectUseCase(indexPath: indexPath, actionDispatcher: actionDispatcher)
    }

}

extension GeoFenceRuleTypeAndScopeDependencyContainer: SaveGeoFenceRuleUseCaseFactory {

    func makeSaveGeoFenceRuleUseCase(completion: SaveGeoFenceRuleUseCase.Completion?) -> UseCase {
        return SaveGeoFenceRuleUseCase(rule: stateStore.state.rule, actionDispatcher: actionDispatcher, completion: completion)
    }

}
