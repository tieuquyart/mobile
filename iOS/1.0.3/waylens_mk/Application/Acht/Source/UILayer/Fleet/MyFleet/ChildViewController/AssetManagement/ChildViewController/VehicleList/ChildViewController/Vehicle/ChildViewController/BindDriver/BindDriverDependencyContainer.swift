//
//  BindDriverDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class BindDriverDependencyContainer {

    let stateStore: ReSwift.Store<BindDriverViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    private let vehicleActionDispatcher: ActionDispatcher

    init(vehicleDependencyContainer: VehicleDependencyContainer) {
        self.stateStore = ReSwift.Store(reducer: Reducers.BindDriverReducer, state: BindDriverViewControllerState(vehicleProfile: vehicleDependencyContainer.stateStore.state.vehicleProfile))
        self.vehicleActionDispatcher = vehicleDependencyContainer.actionDispatcher
    }

    func makeBindDriverViewController() -> BindDriverViewController {
        let stateObservable = makeBindDriverViewControllerStateObservable()
        let observer = ObserverForBindDriver(state: stateObservable)
        let userInterface = BindDriverRootView()
        let viewController = BindDriverViewController(
            observer: observer,
            userInterface: userInterface,
            loadMemberListUseCaseFactory: self,
            selectorSelectUseCaseFactory: self,
            bindDriverUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension BindDriverDependencyContainer {

    func makeBindDriverViewControllerStateObservable() -> Observable<BindDriverViewControllerState> {
        return stateStore.makeObservable()
    }

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<BindDriverFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

//MARK: - UseCase

extension BindDriverDependencyContainer: LoadMemberListUseCaseFactory {

    func makeLoadMemberListUseCase() -> LoadMemberListUseCase {
        return LoadMemberListUseCase(personnelManagementRepository: PersonnelManagementRepository(), actionDispatcher: actionDispatcher)
    }

}

extension BindDriverDependencyContainer: SelectorSelectUseCaseFactory, SelectorFinishUseCaseFactory {

    func makeSelectorSelectUseCase(indexPath: IndexPath) -> UseCase {
        return SelectorSelectUseCase(indexPath: indexPath, actionDispatcher: actionDispatcher)
    }

    func makeSelectorFinishUseCase() -> UseCase {
        return SelectorFinishUseCase(selectedItem: nil, actionDispatcher: actionDispatcher)
    }
}

extension BindDriverDependencyContainer: BindDriverUseCaseFactory {

    func makeBindDriverUseCase() -> UseCase {
        let selectedDriver = stateStore.state.dataSource.selectedItem

        // if has bound, then unbind
        if selectedDriver?.driverID == stateStore.state.vehicleProfile?.driverID {
            return UnbindDriverUseCase(
                vehicleID: stateStore.state.vehicleProfile!.vehicleID!,
                driver: selectedDriver!,
                actionDispatcher: actionDispatcher,
                vehicleActionDispatcher: vehicleActionDispatcher
            )
        } else {
            if let driverID = stateStore.state.vehicleProfile?.driverID, !driverID.isEmpty {
                return UpdateDriverBindingUseCase(
                    vehicleID: stateStore.state.vehicleProfile!.vehicleID!,
                    driver: selectedDriver!,
                    actionDispatcher: actionDispatcher,
                    vehicleActionDispatcher: vehicleActionDispatcher
                )
            } else {
                return BindDriverUseCase(
                    vehicleID: stateStore.state.vehicleProfile!.vehicleID!,
                    driver: selectedDriver!,
                    actionDispatcher: actionDispatcher,
                    vehicleActionDispatcher: vehicleActionDispatcher
                )
            }
        }
    }
}
