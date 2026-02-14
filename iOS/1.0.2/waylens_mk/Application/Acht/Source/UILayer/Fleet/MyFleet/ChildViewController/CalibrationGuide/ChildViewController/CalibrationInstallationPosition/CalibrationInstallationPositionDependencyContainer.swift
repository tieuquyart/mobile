//
//  CalibrationInstallationPositionDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class CalibrationInstallationPositionDependencyContainer {

    let stateStore: ReSwift.Store<CalibrationInstallationPositionViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.CalibrationInstallationPositionReducer, state: CalibrationInstallationPositionViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeCalibrationInstallationPositionViewController() -> CalibrationInstallationPositionViewController {
        let stateObservable = makeCalibrationInstallationPositionViewControllerStateObservable()
        let observer = ObserverForCalibrationInstallationPosition(state: stateObservable)
        let userInterface = CalibrationInstallationPositionRootView()
        let viewController = CalibrationInstallationPositionViewController(
            observer: observer,
            userInterface: userInterface,
            viewControllerFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension CalibrationInstallationPositionDependencyContainer {

    func makeCalibrationInstallationPositionViewControllerStateObservable() -> Observable<CalibrationInstallationPositionViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension CalibrationInstallationPositionDependencyContainer: CalibrationInstallationPositionViewControllerFactory {


}

//MARK: - Use Case

extension CalibrationInstallationPositionDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<CalibrationInstallationPositionFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}
