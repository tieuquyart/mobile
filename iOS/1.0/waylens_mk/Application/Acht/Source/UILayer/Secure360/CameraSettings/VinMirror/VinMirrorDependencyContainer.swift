//
//  VinMirrorDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class VinMirrorDependencyContainer {

    let stateStore: ReSwift.Store<VinMirrorViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.VinMirrorReducer, state: VinMirrorViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    private let camera: UnifiedCamera

    init(camera: UnifiedCamera) {
        self.camera = camera
    }

    func makeVinMirrorViewController() -> VinMirrorViewController {
        let stateObservable = makeVinMirrorViewControllerStateObservable()
        let observer = ObserverForVinMirror(state: stateObservable)
        let cameraObserver = CameraObserverForVinMirror(camera: camera)
        let userInterface = VinMirrorRootView()
        let viewController = VinMirrorViewController(
            observer: observer,
            cameraObserver: cameraObserver,
            userInterface: userInterface,
            updatepdateCameraVinMirrorsUseCaseFactory: self,
            configCameraVinMirrorsUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        viewController.camera = camera
        observer.eventResponder = viewController
        cameraObserver.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension VinMirrorDependencyContainer {

    func makeVinMirrorViewControllerStateObservable() -> Observable<VinMirrorViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension VinMirrorDependencyContainer: VinMirrorViewControllerFactory {


}

//MARK: - Use Case

extension VinMirrorDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<VinMirrorFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension VinMirrorDependencyContainer: UpdateCameraVinMirrorsUseCaseFactory {

    func makeUpdateCameraVinMirrorsUseCase() -> UseCase {
        return UpdateCameraVinMirrorsUseCase(camera: camera, actionDispatcher: actionDispatcher)
    }

}

extension VinMirrorDependencyContainer: ConfigCameraVinMirrorsUseCaseFactory {

    func makeConfigCameraVinMirrorsUseCase(with vinMirrors: [VinMirror]) -> UseCase {
        return ConfigCameraVinMirrorsUseCase(camera: camera, vinMirrors: vinMirrors)
    }
}
