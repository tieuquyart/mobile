//
//  RecordConfigDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class RecordConfigDependencyContainer {

    let stateStore: ReSwift.Store<RecordConfigViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.RecordConfigReducer, state: RecordConfigViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    private let camera: UnifiedCamera

    init(camera: UnifiedCamera) {
        self.camera = camera
    }

    func makeRecordConfigViewController() -> RecordConfigViewController {
        let stateObservable = makeRecordConfigViewControllerStateObservable()
        let observer = ObserverForRecordConfig(state: stateObservable)
        let cameraObserver = CameraObserverForRecordConfig(camera: camera)
        let userInterface = RecordConfigRootView()
        let viewController = RecordConfigViewController(
            observer: observer,
            cameraObserver: cameraObserver,
            userInterface: userInterface,
            updateCameraRecordConfigListUseCaseFactory: self,
            updateCameraRecordConfigUseCaseFactory: self,
            applyCameraRecordConfigUseCaseFactory: self,
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

private extension RecordConfigDependencyContainer {

    func makeRecordConfigViewControllerStateObservable() -> Observable<RecordConfigViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension RecordConfigDependencyContainer: RecordConfigViewControllerFactory {


}

//MARK: - Use Case

extension RecordConfigDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<RecordConfigFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension RecordConfigDependencyContainer: UpdateCameraRecordConfigListUseCaseFactory {

    func makeUpdateCameraRecordConfigListUseCase() -> UseCase {
        return UpdateCameraRecordConfigListUseCase(camera: camera, actionDispatcher: actionDispatcher)
    }

}

extension RecordConfigDependencyContainer: UpdateCameraRecordConfigUseCaseFactory {

    func makeUpdateCameraRecordConfigUseCase() -> UseCase {
        return UpdateCameraRecordConfigUseCase(camera: camera, actionDispatcher: actionDispatcher)
    }

}

extension RecordConfigDependencyContainer: ApplyCameraRecordConfigUseCaseFactory {

    func makeApplyCameraRecordConfigUseCase(recordConfig: String, bitrateFactor: Int, forceCodec: Int) -> UseCase {
        return ApplyCameraRecordConfigUseCase(camera: camera, recordConfig: recordConfig, bitrateFactor: bitrateFactor, forceCodec: forceCodec, actionDispatcher: actionDispatcher)
    }
    
}
