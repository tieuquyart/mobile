//
//  InstallationDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class InstallationDependencyContainer {

    let stateStore: ReSwift.Store<InstallationViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.InstallationReducer, state: InstallationViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeInstallationViewController() -> InstallationViewController {
        let stateObservable = makeInstallationViewControllerStateObservable()
        let observer = ObserverForInstallation(state: stateObservable)
        let userInterface = InstallationRootView()
        let viewController = InstallationViewController(
            observer: observer,
            userInterface: userInterface,
            viewControllerFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension InstallationDependencyContainer {

    func makeInstallationViewControllerStateObservable() -> Observable<InstallationViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension InstallationDependencyContainer: InstallationViewControllerFactory {

    func makeViewControllerForStartingInstallation() -> UIViewController {
        return CameraTypeSelectionDependencyContainer(scene: .installation).makeCameraTypeSelectionViewController()
    }

}

//MARK: - Use Case

extension InstallationDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<InstallationFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}
