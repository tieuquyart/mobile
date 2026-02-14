//
//  VehicleListDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class VehicleListDependencyContainer {

    let stateStore: ReSwift.Store<VehicleListViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.VehicleListReducer, state: VehicleListViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeVehicleListViewController() -> VehicleListViewController {
        let stateObservable = makeVehicleListViewControllerStateObservable()
        let observer = ObserverForVehicleList(state: stateObservable)
        let userInterface = VehicleListRootView()
        let viewController = VehicleListViewController(
            observer: observer,
            userInterface: userInterface,
            loadVehicleListUseCaseFactory: self,
            vehicleListViewControllerFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension VehicleListDependencyContainer {

    func makeVehicleListViewControllerStateObservable() -> Observable<VehicleListViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension VehicleListDependencyContainer: VehicleListViewControllerFactory {

    func makeVehicleViewController(with vehicleIndex: Int) -> UIViewController {
        let v = stateStore.state.dataSource.provider.items[0][vehicleIndex]
        return VehicleDependencyContainer(vehicleProfile: v).makeVehicleViewController()
    }

    func makeAddNewVehicleViewController() -> UIViewController {
        return AddNewVehicleDependencyContainer().makeAddNewVehicleViewController()
    }

}

//MARK: - UseCase

extension VehicleListDependencyContainer: LoadVehicleListUseCaseFactory {

    func makeLoadVehicleListUseCase() -> UseCase {
        return LoadVehicleListUseCase(actionDispatcher: actionDispatcher)
    }

}

extension VehicleListDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<VehicleListFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}
