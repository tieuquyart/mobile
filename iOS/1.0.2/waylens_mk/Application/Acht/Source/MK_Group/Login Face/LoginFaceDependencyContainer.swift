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

class LoginFaceDependencyContainer {

    let stateStore: ReSwift.Store<LoginFaceViewControllerState> = {
        
        return ReSwift.Store(reducer: Reducers.LoginFaceReducer, state: LoginFaceViewControllerState())
        
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeLoginFaceViewController() -> LoginFaceViewController {
        let stateObservable = makeLoginFaceViewControllerStateObservable()
        let stateObserver = ObserverForLoginFace(state: stateObservable)
        let cameraObserver = ObserverForCurrentConnectedCamera()
        let cameraKeyPathObserver = KeyPathObserverForCurrentConnectedCamera(keyPathsToObserve: \WLCameraDevice.recState, \WLCameraDevice.recordConfig, \WLCameraDevice.vinMirrorList)
        let composedObservers =
            ObserverComposition(observers: stateObserver, cameraObserver, cameraKeyPathObserver)

        let userInterface = LoginFaceRootView()
        
        let viewController = LoginFaceViewController(
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

private extension LoginFaceDependencyContainer {

    func makeLoginFaceViewControllerStateObservable() -> Observable<LoginFaceViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension LoginFaceDependencyContainer: LoginFaceViewControllerFactory {


}

//MARK: - Use Case

extension LoginFaceDependencyContainer {

    func makeFinishedPresentingErrorUseCase (
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<LoginFaceFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}

extension LoginFaceDependencyContainer: JudgeDmsCameraPositionUseCaseFactory {

    func makeJudgeCameraPositionUseCase(dmsData: WLDmsData?) -> UseCase {
        return JudgeDmsCameraPositionUseCase(
            dmsData: dmsData,
            needsValidGaze: false,
            actionDispatcher: actionDispatcher
        )
    }
}
