//
//  CameraDetailDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class CameraDetailDependencyContainer {

    let stateStore: ReSwift.Store<CameraDetailViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(cameraSN: String, plateNumber: String) {
        let info = CameraInfo(cameraSN: cameraSN, vehiclePlateNumber: plateNumber)
        self.stateStore = ReSwift.Store(reducer: Reducers.CameraDetailReducer, state: CameraDetailViewControllerState(cameraInfo: info))
    }

    func makeCameraDetailViewController() -> CameraDetailViewController {
        let stateObservable = makeCameraDetailViewControllerStateObservable()
        let observer = ObserverForCameraDetail(state: stateObservable)
        let userInterface = CameraDetailRootView()
        let viewController = CameraDetailViewController(
            observer: observer,
            userInterface: userInterface,
            fetchCameraInfoUseCaseFactory: self,
            toggleFirmwareVersionUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension CameraDetailDependencyContainer {

    func makeCameraDetailViewControllerStateObservable() -> Observable<CameraDetailViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension CameraDetailDependencyContainer: CameraDetailViewControllerFactory {


}

//MARK: - Use Case

extension CameraDetailDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<CameraDetailFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension CameraDetailDependencyContainer: FetchCameraInfoUseCaseFactory {

    func makeFetchCameraInfoUseCase() -> UseCase? {
        guard let cameraSN = stateStore.state.cameraInfo?.cameraSN, !cameraSN.isEmpty else {
            return nil
        }
        return FetchCameraInfoUseCase(cameraSN: cameraSN, actionDispatcher: actionDispatcher)
    }

}

extension CameraDetailDependencyContainer: ToggleFirmwareVersionUseCaseFactory {

    func makeToggleFirmwareVersionUseCase() -> UseCase {
        return ToggleFirmwareVersionUseCase(actionDispatcher: actionDispatcher)
    }

}

