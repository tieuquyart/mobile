//
//  ObdWorkModeDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift
import WaylensCameraSDK

class ObdWorkModeDependencyContainer {

    let stateStore: ReSwift.Store<ObdWorkModeViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.ObdWorkModeReducer, state: ObdWorkModeViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeObdWorkModeViewController() -> ObdWorkModeViewController {
        let stateObservable = makeObdWorkModeViewControllerStateObservable()
        let stateObserver = ObserverForObdWorkMode(state: stateObservable)
        let cameraObserver = ObserverForCurrentConnectedCamera()
        let cameraKeyPathObserver = KeyPathObserverForCurrentConnectedCamera(keyPathsToObserve: \WLCameraDevice.obdWorkModeConfig)
        let composedObservers =
            ObserverComposition(observers: stateObserver, cameraObserver, cameraKeyPathObserver)

        let userInterface = ObdWorkModeRootView()
        let viewController = ObdWorkModeViewController(
            observer: composedObservers,
            userInterface: userInterface,
            viewControllerFactory: self,
            updateObdWorkModeConfigUseCaseFactory: self,
            generalUseCaseFactory: self,
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

private extension ObdWorkModeDependencyContainer {

    func makeObdWorkModeViewControllerStateObservable() -> Observable<ObdWorkModeViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension ObdWorkModeDependencyContainer: ObdWorkModeViewControllerFactory {


}

//MARK: - Use Case

extension ObdWorkModeDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<ObdWorkModeFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}

extension ObdWorkModeDependencyContainer: UpdateObdWorkModeConfigUseCaseFactory {

    func makeUpdateObdWorkModeConfigUseCase(mode: WLObdWorkMode) -> UseCase {
        var newConfigDict = stateStore.state.config!.rawData
        newConfigDict[WLObdWorkModeConfigKeys.mode.rawValue] = mode.rawValue
        let newConfig = WLObdWorkModeConfig(dictionary: newConfigDict)
        return UpdateObdWorkModeConfigUseCase(camera: WLBonjourCameraListManager.shared.currentCamera, config: newConfig!, actionDispatcher: actionDispatcher)
    }

    func makeUpdateObdWorkModeConfigUseCase(voltageOff: Int) -> UseCase {
        var newConfigDict = stateStore.state.config!.rawData
        newConfigDict[WLObdWorkModeConfigKeys.voff.rawValue] = voltageOff
        let newConfig = WLObdWorkModeConfig(dictionary: newConfigDict)
        return UpdateObdWorkModeConfigUseCase(camera: WLBonjourCameraListManager.shared.currentCamera, config: newConfig!, actionDispatcher: actionDispatcher)
    }

    func makeUpdateObdWorkModeConfigUseCase(voltageOn: Int) -> UseCase {
        var newConfigDict = stateStore.state.config!.rawData
        newConfigDict[WLObdWorkModeConfigKeys.von.rawValue] = voltageOn
        let newConfig = WLObdWorkModeConfig(dictionary: newConfigDict)
        return UpdateObdWorkModeConfigUseCase(camera: WLBonjourCameraListManager.shared.currentCamera, config: newConfig!, actionDispatcher: actionDispatcher)
    }

    func makeUpdateObdWorkModeConfigUseCase(voltageCheck: Int) -> UseCase {
        var newConfigDict = stateStore.state.config!.rawData
        newConfigDict[WLObdWorkModeConfigKeys.vchk.rawValue] = voltageCheck
        let newConfig = WLObdWorkModeConfig(dictionary: newConfigDict)
        return UpdateObdWorkModeConfigUseCase(camera: WLBonjourCameraListManager.shared.currentCamera, config: newConfig!, actionDispatcher: actionDispatcher)
    }

}

extension ObdWorkModeDependencyContainer: GeneralUseCaseFactory {

    func makeGeneralUseCase(value: Any) -> UseCase {
        return GeneralUseCase(value: value, actionDispatcher: actionDispatcher)
    }
    
}
