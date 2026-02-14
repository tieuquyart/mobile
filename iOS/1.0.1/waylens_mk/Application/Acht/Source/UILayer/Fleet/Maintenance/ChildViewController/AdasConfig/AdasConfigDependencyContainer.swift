//
//  AdasConfigDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift
import WaylensCameraSDK

class AdasConfigDependencyContainer {

    let stateStore: ReSwift.Store<AdasConfigViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.AdasConfigReducer, state: AdasConfigViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeAdasConfigViewController() -> AdasConfigViewController {
        let stateObservable = makeAdasConfigViewControllerStateObservable()
        let stateObserver = ObserverForAdasConfig(state: stateObservable)
        let cameraObserver = ObserverForCurrentConnectedCamera()
        let cameraKeyPathObserver = KeyPathObserverForCurrentConnectedCamera(keyPathsToObserve: \WLCameraDevice.adasConfig)
        let composedObservers =
            ObserverComposition(observers: stateObserver, cameraKeyPathObserver, cameraObserver)
        
        let userInterface = AdasConfigRootView()
        let viewController = AdasConfigViewController(
            observer: composedObservers,
            userInterface: userInterface,
            viewControllerFactory: self,
            generalUseCaseFactory: self,
            applyCameraAdasConfigUseCaseFactory: self,
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

private extension AdasConfigDependencyContainer {

    func makeAdasConfigViewControllerStateObservable() -> Observable<AdasConfigViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension AdasConfigDependencyContainer: AdasConfigViewControllerFactory {


}

//MARK: - Use Case

extension AdasConfigDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<AdasConfigFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}

extension AdasConfigDependencyContainer: GeneralUseCaseFactory {

    func makeGeneralUseCase(value: Any) -> UseCase {
        return GeneralUseCase(value: value, actionDispatcher: actionDispatcher)
    }

}

extension AdasConfigDependencyContainer: ApplyCameraAdasConfigUseCaseFactory {
    
    func makeApplyCameraAdasConfigUseCase(key: AnyKeyPath, value: String?) -> UseCase {
        return ApplyCameraAdasConfigUseCase(
            camera: UnifiedCamera(local: WLBonjourCameraListManager.shared.currentCamera, remote: nil),
            key: key,
            value: value,
            actionDispatcher: actionDispatcher
        )
    }
    
}
