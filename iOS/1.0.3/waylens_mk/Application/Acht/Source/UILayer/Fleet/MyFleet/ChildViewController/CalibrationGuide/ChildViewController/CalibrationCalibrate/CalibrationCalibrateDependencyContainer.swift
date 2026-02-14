//
//  CalibrationCalibrateDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift
import WaylensCameraSDK

class CalibrationCalibrateDependencyContainer {

    let stateStore: ReSwift.Store<CalibrationCalibrateViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.CalibrationCalibrateReducer, state: CalibrationCalibrateViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeCalibrationCalibrateViewController() -> CalibrationCalibrateViewController {
        let stateObservable = makeCalibrationCalibrateViewControllerStateObservable()
        let stateObserver = ObserverForCalibrationCalibrate(state: stateObservable)
        let cameraObserver = ObserverForCurrentConnectedCamera()
        let cameraKeyPathObserver = KeyPathObserverForCurrentConnectedCamera(keyPathsToObserve: \WLCameraDevice.recState, \WLCameraDevice.recordConfig, \WLCameraDevice.vinMirrorList)
        let composedObservers =
            ObserverComposition(observers: stateObserver, cameraObserver, cameraKeyPathObserver)

        let userInterface = CalibrationCalibrateRootView()
        let viewController = CalibrationCalibrateViewController(
            dmsClient: WLDmsClient(iPv4: WLBonjourCameraListManager.shared.currentCamera!.getIPV4(), iPv6: nil, port: 1368),
            observer: composedObservers,
            userInterface: userInterface,
            countDownUseCaseFactory: self,
            viewControllerFactory: self,
            judgeDmsCameraPositionUseCaseFactory: self,
            calibrateAgainUseCaseFactory: self,
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

private extension CalibrationCalibrateDependencyContainer {

    func makeCalibrationCalibrateViewControllerStateObservable() -> Observable<CalibrationCalibrateViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension CalibrationCalibrateDependencyContainer: CalibrationCalibrateViewControllerFactory {


}

//MARK: - Use Case

extension CalibrationCalibrateDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<CalibrationCalibrateFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}

extension CalibrationCalibrateDependencyContainer: CountDownUseCaseFactory {

    func makeCountDownUseCase() -> UseCase {
        return CountDownUseCase(interval: 1, repeatTimes: 3, actionDispatcher: actionDispatcher)
    }

}

extension CalibrationCalibrateDependencyContainer: JudgeDmsCameraPositionUseCaseFactory {

    func makeJudgeCameraPositionUseCase(dmsData: WLDmsData?) -> UseCase {
        return JudgeDmsCameraPositionUseCase(
            dmsData: dmsData,
            actionDispatcher: actionDispatcher
        )
    }

}

extension CalibrationCalibrateDependencyContainer: CalibrateAgainUseCaseFactory {

    func makeCalibrateAgainUseCase() -> UseCase {
        return CalibrateAgainUseCase(actionDispatcher: actionDispatcher)
    }

}
