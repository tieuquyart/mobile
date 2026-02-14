//
//  DriverSelectorDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class DriverSelectorDependencyContainer {

    let stateStore: ReSwift.Store<DriverSelectorViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    private let consumerActionDispatcher: ActionDispatcher

    init(vehicleProfile: VehicleProfile?, consumerActionDispatcher: ActionDispatcher) {
        self.stateStore = ReSwift.Store(reducer: Reducers.DriverSelectorReducer, state: DriverSelectorViewControllerState(vehicleProfile: vehicleProfile))
        self.consumerActionDispatcher = consumerActionDispatcher
    }

    func makeDriverSelectorViewController() -> DriverSelectorViewController {
        let stateObservable = makeDriverSelectorViewControllerStateObservable()
        let observer = ObserverForDriverSelector(state: stateObservable)
        let userInterface = DriverSelectorRootView()
        let viewController = DriverSelectorViewController(
            observer: observer,
            userInterface: userInterface,
            loadMemberListUseCaseFactory: self,
            selectorSelectUseCaseFactory: self,
            selectorFinishUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension DriverSelectorDependencyContainer {

    func makeDriverSelectorViewControllerStateObservable() -> Observable<DriverSelectorViewControllerState> {
        return stateStore.makeObservable()
    }

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<DriverSelectorFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

//MARK: - UseCase

extension DriverSelectorDependencyContainer: LoadMemberListUseCaseFactory {

    func makeLoadMemberListUseCase() -> LoadMemberListUseCase {
        return LoadMemberListUseCase(personnelManagementRepository: PersonnelManagementRepository(), actionDispatcher: actionDispatcher)
    }

}

extension DriverSelectorDependencyContainer: SelectorSelectUseCaseFactory, SelectorFinishUseCaseFactory {

    func makeSelectorSelectUseCase(indexPath: IndexPath) -> UseCase {
        return SelectorSelectUseCase(indexPath: indexPath, actionDispatcher: actionDispatcher)
    }

    func makeSelectorFinishUseCase() -> UseCase {
        return SelectorFinishUseCase(selectedItem: stateStore.state.dataSource.selectedItem, actionDispatcher: consumerActionDispatcher)
    }
}
