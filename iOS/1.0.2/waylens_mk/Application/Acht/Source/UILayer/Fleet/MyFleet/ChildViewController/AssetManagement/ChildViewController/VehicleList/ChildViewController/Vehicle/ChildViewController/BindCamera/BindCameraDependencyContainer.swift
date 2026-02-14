//
//  BindCameraDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class BindCameraDependencyContainer {

    let stateStore: ReSwift.Store<BindCameraViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    private let vehicleActionDispatcher: ActionDispatcher

    init(vehicleDependencyContainer: VehicleDependencyContainer) {
        self.stateStore = ReSwift.Store(reducer: Reducers.BindCameraReducer, state: BindCameraViewControllerState(vehicleProfile: vehicleDependencyContainer.stateStore.state.vehicleProfile))
        self.vehicleActionDispatcher = vehicleDependencyContainer.actionDispatcher
    }

    func makeBindCameraViewController() -> BindCameraViewController {
        let stateObservable = makeBindCameraViewControllerStateObservable()
        let observer = ObserverForBindCamera(state: stateObservable)
        let userInterface = BindCameraRootView()
        let viewController = BindCameraViewController(
            observer: observer,
            userInterface: userInterface,
            loadCameraListUseCaseFactory: self,
            selectorSelectUseCaseFactory: self,
            bindCameraUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension BindCameraDependencyContainer {

    func makeBindCameraViewControllerStateObservable() -> Observable<BindCameraViewControllerState> {
        return stateStore.makeObservable()
    }

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<BindCameraFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

//MARK: - UseCase

extension BindCameraDependencyContainer: LoadCameraListUseCaseFactory {

    func makeLoadCameraListUseCase() -> UseCase {
        return LoadCameraListUseCase(actionDispatcher: actionDispatcher)
    }
}

extension BindCameraDependencyContainer: SelectorSelectUseCaseFactory, SelectorFinishUseCaseFactory {

    func makeSelectorSelectUseCase(indexPath: IndexPath) -> UseCase {
        return SelectorSelectUseCase(indexPath: indexPath, actionDispatcher: actionDispatcher)
    }

    func makeSelectorFinishUseCase() -> UseCase {
        return SelectorFinishUseCase(selectedItem: nil, actionDispatcher: actionDispatcher)
    }
}

extension BindCameraDependencyContainer: BindCameraUseCaseFactory {

    func makeBindCameraUseCase() -> UseCase {
        let selectedCamera = stateStore.state.dataSource.selectedItem

        return BindCameraUseCase(
            vehicleID: stateStore.state.vehicleProfile!.vehicleID!,
            cameraSN: selectedCamera!.cameraSn,
            actionDispatcher: actionDispatcher,
            vehicleActionDispatcher: vehicleActionDispatcher
        )
    }
}
