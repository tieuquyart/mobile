//
//  ActivateCameraDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class ActivateCameraDependencyContainer {
    let stateStore: ReSwift.Store<ActivateCameraViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(camera: CameraProfile) {
        stateStore = ReSwift.Store(reducer: Reducers.ActivateCameraReducer, state: ActivateCameraViewControllerState(camera: camera))
    }

    func makeActivateCameraViewController() -> ActivateCameraViewController {
        let stateObservable = makeActivateCameraViewControllerStateObservable()
        let observer = ObserverForActivateCamera(state: stateObservable)
        let userInterface = ActivateCameraRootView()
        let viewController = ActivateCameraViewController(
            observer: observer,
            userInterface: userInterface,
            activateCameraSimCardUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension ActivateCameraDependencyContainer {

    func makeActivateCameraViewControllerStateObservable() -> Observable<ActivateCameraViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension ActivateCameraDependencyContainer: ActivateCameraViewControllerFactory {


}

//MARK: - Use Case

extension ActivateCameraDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<ActivateCameraFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension ActivateCameraDependencyContainer: ActivateCameraSimCardUseCaseFactory {

    func makeActivateCameraSimCardUseCase() -> UseCase {
        return ActivateCameraSimCardUseCase(cameraSN: stateStore.state.camera!.cameraSn, actionDispatcher: actionDispatcher)
    }
}
