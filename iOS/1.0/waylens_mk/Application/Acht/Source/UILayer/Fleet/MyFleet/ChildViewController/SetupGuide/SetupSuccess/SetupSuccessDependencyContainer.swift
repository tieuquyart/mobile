//
//  SetupSuccessDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class SetupSuccessDependencyContainer {

    let stateStore: ReSwift.Store<SetupSuccessViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(vehicle: VehicleProfile? = nil, driver: FleetMember? = nil, camera: CameraProfile? = nil) {
        self.stateStore = ReSwift.Store(reducer: Reducers.SetupSuccessReducer, state: SetupSuccessViewControllerState(vehicle: vehicle, driver: driver, camera: camera))
    }

    func makeSetupSuccessViewController() -> SetupSuccessViewController {
        let stateObservable = makeSetupSuccessViewControllerStateObservable()
        let observer = ObserverForSetupSuccess(state: stateObservable)
        let userInterface = SetupSuccessRootView()
        let viewController = SetupSuccessViewController(
            observer: observer,
            userInterface: userInterface,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension SetupSuccessDependencyContainer {

    func makeSetupSuccessViewControllerStateObservable() -> Observable<SetupSuccessViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension SetupSuccessDependencyContainer: SetupSuccessViewControllerFactory {


}

//MARK: - Use Case

extension SetupSuccessDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<SetupSuccessFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}
