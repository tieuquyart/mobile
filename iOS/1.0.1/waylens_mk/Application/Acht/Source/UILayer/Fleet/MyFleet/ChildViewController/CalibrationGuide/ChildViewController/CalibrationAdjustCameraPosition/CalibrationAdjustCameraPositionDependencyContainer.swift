//
//  CalibrationAdjustCameraPositionDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift
import WaylensCameraSDK

class CalibrationAdjustCameraPositionDependencyContainer {

    let stateStore: ReSwift.Store<CalibrationAdjustCameraPositionViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.CalibrationAdjustCameraPositionReducer, state: CalibrationAdjustCameraPositionViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeCalibrationAdjustCameraPositionViewController() -> CalibrationAdjustCameraPositionViewController {
        let stateObservable = makeCalibrationAdjustCameraPositionViewControllerStateObservable()
        let stateObserver = ObserverForCalibrationAdjustCameraPosition(state: stateObservable)
        let cameraObserver = ObserverForCurrentConnectedCamera()
        let cameraKeyPathObserver = KeyPathObserverForCurrentConnectedCamera(keyPathsToObserve: \WLCameraDevice.recState, \WLCameraDevice.recordConfig, \WLCameraDevice.vinMirrorList)
        let composedObservers =
            ObserverComposition(observers: stateObserver, cameraObserver, cameraKeyPathObserver)

        let userInterface = CalibrationAdjustCameraPositionRootView()
        let viewController = CalibrationAdjustCameraPositionViewController(
            observer: composedObservers,
            userInterface: userInterface,
            viewControllerFactory: self,
            judgeDmsCameraPositionUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        stateObserver.eventResponder = viewController
        cameraObserver.eventResponder = viewController
        cameraKeyPathObserver.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension CalibrationAdjustCameraPositionDependencyContainer {

    func makeCalibrationAdjustCameraPositionViewControllerStateObservable() -> Observable<CalibrationAdjustCameraPositionViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension CalibrationAdjustCameraPositionDependencyContainer: CalibrationAdjustCameraPositionViewControllerFactory {


}

//MARK: - Use Case

extension CalibrationAdjustCameraPositionDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<CalibrationAdjustCameraPositionFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}

extension CalibrationAdjustCameraPositionDependencyContainer: JudgeDmsCameraPositionUseCaseFactory {

    func makeJudgeCameraPositionUseCase(dmsData: WLDmsData?) -> UseCase {
        return JudgeDmsCameraPositionUseCase(
            dmsData: dmsData,
            needsValidGaze: false,
            actionDispatcher: actionDispatcher
        )
    }
}
