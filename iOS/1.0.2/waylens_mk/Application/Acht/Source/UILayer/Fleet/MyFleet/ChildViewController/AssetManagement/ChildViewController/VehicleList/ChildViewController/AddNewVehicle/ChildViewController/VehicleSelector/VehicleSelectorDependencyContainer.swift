//
//  VehicleSelectorDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class VehicleSelectorDependencyContainer {

    let stateStore: ReSwift.Store<VehicleSelectorViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    private let consumerActionDispatcher: ActionDispatcher

    init(vehicleProfile: VehicleProfile?, consumerActionDispatcher: ActionDispatcher) {
        self.stateStore = ReSwift.Store(reducer: Reducers.VehicleSelectorReducer, state: VehicleSelectorViewControllerState(vehicleProfile: vehicleProfile))
        self.consumerActionDispatcher = consumerActionDispatcher
    }

    func makeVehicleSelectorViewController() -> VehicleSelectorViewController {
        let stateObservable = makeVehicleSelectorViewControllerStateObservable()
        let observer = ObserverForVehicleSelector(state: stateObservable)
        let userInterface = VehicleSelectorRootView()
        let viewController = VehicleSelectorViewController(
            observer: observer,
            userInterface: userInterface,
            vehicleSelectorViewControllerFactory: self,
            loadVehicleListUseCaseFactory: self,
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

private extension VehicleSelectorDependencyContainer {

    func makeVehicleSelectorViewControllerStateObservable() -> Observable<VehicleSelectorViewControllerState> {
        return stateStore.makeObservable()
    }

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<VehicleSelectorFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension VehicleSelectorDependencyContainer: VehicleSelectorViewControllerFactory {

    func makeAddNewPlateNumberViewController() -> UIViewController {
        return AddNewPlateNumberDependencyContainer().makeAddNewPlateNumberViewController()
    }

}

//MARK: - UseCase

extension VehicleSelectorDependencyContainer: LoadVehicleListUseCaseFactory {

    func makeLoadVehicleListUseCase() -> UseCase {
        return LoadVehicleListUseCase(actionDispatcher: actionDispatcher)
    }

}

extension VehicleSelectorDependencyContainer: SelectorSelectUseCaseFactory, SelectorFinishUseCaseFactory {

    func makeSelectorSelectUseCase(indexPath: IndexPath) -> UseCase {
        return SelectorSelectUseCase(indexPath: indexPath, actionDispatcher: actionDispatcher)
    }

    func makeSelectorFinishUseCase() -> UseCase {
        return SelectorFinishUseCase(selectedItem: stateStore.state.dataSource.selectedItem, actionDispatcher: consumerActionDispatcher)
    }
}
