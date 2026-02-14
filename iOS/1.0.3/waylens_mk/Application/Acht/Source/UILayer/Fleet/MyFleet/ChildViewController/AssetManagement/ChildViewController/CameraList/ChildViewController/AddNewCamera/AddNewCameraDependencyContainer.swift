//
//  AddNewCameraDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class AddNewCameraDependencyContainer {

    let stateStore: ReSwift.Store<AddNewCameraViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.AddNewCameraReducer, state: AddNewCameraViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeAddNewCameraViewController() -> AddNewCameraViewController {
        let stateObservable = makeAddNewCameraViewControllerStateObservable()
        let stateObserver = ObserverForAddNewCamera(state: stateObservable)
        let cameraObserver = ObserverForCurrentConnectedCamera()
        let observer = ObserverComposition(observers: stateObserver, cameraObserver)
        let userInterface = AddNewCameraRootView()
        let viewController = AddNewCameraViewController(
            observer: observer,
            userInterface: userInterface,
            addNewCameraUseCaseFactory: self,
            generalUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        stateObserver.eventResponder = viewController
        cameraObserver.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension AddNewCameraDependencyContainer {

    func makeAddNewCameraViewControllerStateObservable() -> Observable<AddNewCameraViewControllerState> {
        return stateStore.makeObservable()
    }

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<AddNewCameraFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

//MARK: - Use Case

extension AddNewCameraDependencyContainer: AddNewCameraUseCaseFactory {

    func makeAddNewCameraUseCase(cameraSN: String, password: String) -> UseCase {
        return AddNewCameraUseCase(cameraSN: cameraSN, password: password, actionDispatcher: actionDispatcher)
    }

}

extension AddNewCameraDependencyContainer: GeneralUseCaseFactory {

    func makeGeneralUseCase(value: Any) -> UseCase {
        return GeneralUseCase(value: value, actionDispatcher: actionDispatcher)
    }

}
