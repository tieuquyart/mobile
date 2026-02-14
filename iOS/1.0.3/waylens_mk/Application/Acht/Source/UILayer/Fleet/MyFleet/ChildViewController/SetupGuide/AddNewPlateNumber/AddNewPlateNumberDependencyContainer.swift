//
//  AddNewPlateNumberDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class AddNewPlateNumberDependencyContainer {

    let stateStore: ReSwift.Store<AddNewPlateNumberViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.AddNewPlateNumberReducer, state: AddNewPlateNumberViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeAddNewPlateNumberViewController() -> AddNewPlateNumberViewController {
        let stateObservable = makeAddNewPlateNumberViewControllerStateObservable()
        let observer = ObserverForAddNewPlateNumber(state: stateObservable)
        let userInterface = AddNewPlateNumberRootView()
        let viewController = AddNewPlateNumberViewController(
            observer: observer,
            userInterface: userInterface,
            makeAddNewVehicleUseCase: self.makeAddNewVehicleUseCase(plateNumber:),
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension AddNewPlateNumberDependencyContainer {

    func makeAddNewPlateNumberViewControllerStateObservable() -> Observable<AddNewPlateNumberViewControllerState> {
        return stateStore.makeObservable()
    }

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<AddNewPlateNumberFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

//MARK: - Use Case

extension AddNewPlateNumberDependencyContainer {

    func makeAddNewVehicleUseCase(plateNumber: String?) -> UseCase {
        return AddNewVehicleUseCase(
            plateNumber: plateNumber,
            model: "",
            actionDispatcher: actionDispatcher
        )
    }
}
