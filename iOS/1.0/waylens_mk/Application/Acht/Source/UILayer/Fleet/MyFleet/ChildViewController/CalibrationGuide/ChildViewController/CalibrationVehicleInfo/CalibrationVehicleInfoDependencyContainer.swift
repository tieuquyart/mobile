//
//  CalibrationVehicleInfoDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class CalibrationVehicleInfoDependencyContainer {

    let stateStore: ReSwift.Store<CalibrationVehicleInfoViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.CalibrationVehicleInfoReducer, state: CalibrationVehicleInfoViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeCalibrationVehicleInfoViewController() -> CalibrationVehicleInfoViewController {
        let stateObservable = makeCalibrationVehicleInfoViewControllerStateObservable()
        let observer = ObserverForCalibrationVehicleInfo(state: stateObservable)
        let userInterface = CalibrationVehicleInfoRootView()
        let viewController = CalibrationVehicleInfoViewController(
            observer: observer,
            userInterface: userInterface,
            selectorSelectUseCaseFactory: self,
            viewControllerFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension CalibrationVehicleInfoDependencyContainer {

    func makeCalibrationVehicleInfoViewControllerStateObservable() -> Observable<CalibrationVehicleInfoViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension CalibrationVehicleInfoDependencyContainer: CalibrationVehicleInfoViewControllerFactory {


}

//MARK: - Use Case

extension CalibrationVehicleInfoDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<CalibrationVehicleInfoFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}

extension CalibrationVehicleInfoDependencyContainer: SelectorSelectUseCaseFactory {

    func makeSelectorSelectUseCase(indexPath: IndexPath) -> UseCase {
        return SelectorSelectUseCase(indexPath: indexPath, actionDispatcher: actionDispatcher)
    }

}
