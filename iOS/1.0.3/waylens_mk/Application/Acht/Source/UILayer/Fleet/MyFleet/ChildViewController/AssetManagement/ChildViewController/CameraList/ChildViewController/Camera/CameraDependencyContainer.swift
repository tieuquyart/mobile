//
//  CameraDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class CameraDependencyContainer {

    let stateStore: ReSwift.Store<CameraViewControllerState>
    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(cameraProfile: CameraProfile) {
        self.stateStore = ReSwift.Store(reducer: Reducers.CameraReducer, state: CameraViewControllerState(cameraProfile: cameraProfile))
    }

    func makeCameraViewController() -> CameraViewController {
        let stateObservable = makeCameraViewControllerStateObservable()
        let observer = ObserverForCamera(state: stateObservable)
        let userInterface = CameraRootView()
        let viewController = CameraViewController(
            observer: observer,
            userInterface: userInterface,
            initialLoadUseCaseFactory: self,
            removeCameraUseCaseFactory: self,
            activateCameraSimCardUseCaseFactory: self,
            toggleFirmwareVersionUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension CameraDependencyContainer {

    func makeCameraViewControllerStateObservable() -> Observable<CameraViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - UseCase

extension CameraDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<CameraFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension CameraDependencyContainer: InitialLoadUseCaseFactory {

    func makeInitialLoadUseCase() -> UseCase {
        return InitialLoadUseCase(actionDispatcher: actionDispatcher)
    }

}

extension CameraDependencyContainer: RemoveCameraUseCaseFactory {

    func makeRemoveCameraUseCase() -> UseCase {
        let cameraSN = stateStore.state.cameraProfile?.cameraSn
        return RemoveCameraUseCase(cameraSN: cameraSN!, actionDispatcher: actionDispatcher)
    }

}

extension CameraDependencyContainer: ActivateCameraSimCardUseCaseFactory {

    func makeActivateCameraSimCardUseCase() -> UseCase {
        let cameraSN = stateStore.state.cameraProfile?.cameraSn
        return ActivateCameraSimCardUseCase(cameraSN: cameraSN!, actionDispatcher: actionDispatcher)
    }

}

extension CameraDependencyContainer: ToggleFirmwareVersionUseCaseFactory {

    func makeToggleFirmwareVersionUseCase() -> UseCase {
        return ToggleFirmwareVersionUseCase(actionDispatcher: actionDispatcher)
    }
    
}
