//
//  TriggeringVehicleSelectorDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class TriggeringVehicleSelectorDependencyContainer {

    let stateStore: ReSwift.Store<TriggeringVehicleSelectorViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(rule: GeoFenceRuleForEdit) {
        stateStore = ReSwift.Store(reducer: Reducers.TriggeringVehicleSelectorReducer, state: TriggeringVehicleSelectorViewControllerState(rule: rule))
    }

    func makeTriggeringVehicleSelectorViewController() -> TriggeringVehicleSelectorViewController {
        let stateObservable = makeTriggeringVehicleSelectorViewControllerStateObservable()
        let observer = ObserverForTriggeringVehicleSelector(state: stateObservable)
        let userInterface = TriggeringVehicleSelectorRootView()
        let viewController = TriggeringVehicleSelectorViewController(
            observer: observer,
            userInterface: userInterface,
            loadVehicleListUseCaseFactory: self,
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

private extension TriggeringVehicleSelectorDependencyContainer {

    func makeTriggeringVehicleSelectorViewControllerStateObservable() -> Observable<TriggeringVehicleSelectorViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension TriggeringVehicleSelectorDependencyContainer: TriggeringVehicleSelectorViewControllerFactory {


}

//MARK: - Use Case

extension TriggeringVehicleSelectorDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<TriggeringVehicleSelectorFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension TriggeringVehicleSelectorDependencyContainer: LoadVehicleListUseCaseFactory {

    func makeLoadVehicleListUseCase() -> UseCase {
        return LoadVehicleListUseCase(actionDispatcher: actionDispatcher)
    }

}

extension TriggeringVehicleSelectorDependencyContainer: SelectorSelectUseCaseFactory {

    func makeSelectorSelectUseCase(indexPath: IndexPath) -> UseCase {
        return SelectorSelectUseCase(indexPath: indexPath, actionDispatcher: actionDispatcher)
    }

}

extension TriggeringVehicleSelectorDependencyContainer: SaveGeoFenceRuleUseCaseFactory {

    func makeSaveGeoFenceRuleUseCase(completion: SaveGeoFenceRuleUseCase.Completion?) -> UseCase {
        return SaveGeoFenceRuleUseCase(rule: stateStore.state.rule, actionDispatcher: actionDispatcher, completion: completion)
    }

}
