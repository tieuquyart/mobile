//
//  CalibrationCameraOrientationDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift
import WaylensCameraSDK

class CalibrationCameraOrientationDependencyContainer {

    let stateStore: ReSwift.Store<CalibrationCameraOrientationViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.CalibrationCameraOrientationReducer, state: CalibrationCameraOrientationViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeCalibrationCameraOrientationViewController() -> CalibrationCameraOrientationViewController {
        let stateObservable = makeCalibrationCameraOrientationViewControllerStateObservable()
        let stateObserver = ObserverForCalibrationCameraOrientation(state: stateObservable)
        let cameraObserver = ObserverForCurrentConnectedCamera()
        let cameraKeyPathObserver = KeyPathObserverForCurrentConnectedCamera(keyPathsToObserve: \WLCameraDevice.recordConfig, \WLCameraDevice.recState, \WLCameraDevice.vinMirrorList)
        let composedObservers =
            ObserverComposition(observers: stateObserver, cameraObserver, cameraKeyPathObserver)

        let userInterface = CalibrationCameraOrientationRootView()
        let viewController = CalibrationCameraOrientationViewController(
            observer: composedObservers,
            userInterface: userInterface,
            configCameraVinMirrorsUseCaseFactory: self,
            viewControllerFactory: self,
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

private extension CalibrationCameraOrientationDependencyContainer {

    func makeCalibrationCameraOrientationViewControllerStateObservable() -> Observable<CalibrationCameraOrientationViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension CalibrationCameraOrientationDependencyContainer: CalibrationCameraOrientationViewControllerFactory {


}

//MARK: - Use Case

extension CalibrationCameraOrientationDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<CalibrationCameraOrientationFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}

extension CalibrationCameraOrientationDependencyContainer: ConfigCameraVinMirrorsUseCaseFactory {

    func makeConfigCameraVinMirrorsUseCase(with vinMirrors: [VinMirror]) -> UseCase {
        var vinMirrors: [VinMirror] = []

        let currentCamera = UnifiedCamera(local: WLBonjourCameraListManager.shared.currentCamera, remote: nil)

        if let originalVinMirrors = WLBonjourCameraListManager.shared.currentCamera?.vinMirrorList?.compactMap({VinMirror(rawValue: ($0 as? String) ?? "")}) {
            vinMirrors.append(contentsOf: originalVinMirrors)

            if originalVinMirrors.count >= 3 {
                let invertedMirror = originalVinMirrors[2].inverted()
                vinMirrors.replaceSubrange(2...2, with: [invertedMirror])
            }
        }

        return ConfigCameraVinMirrorsUseCase(camera: currentCamera, vinMirrors: vinMirrors)
    }

}
