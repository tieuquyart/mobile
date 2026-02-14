//
//  CameraListDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class CameraListDependencyContainer {

    let stateStore: ReSwift.Store<CameraListViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.CameraListReducer, state: CameraListViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeCameraListViewController() -> CameraListViewController {
        let stateObservable = makeCameraListViewControllerStateObservable()
        let observer = ObserverForCameraList(state: stateObservable)
        let userInterface = CameraListRootView()
        let viewController = CameraListViewController(
            observer: observer,
            userInterface: userInterface,
            loadCameraListUseCaseFactory: self,
            cameraListViewControllerFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension CameraListDependencyContainer {

    func makeCameraListViewControllerStateObservable() -> Observable<CameraListViewControllerState> {
        return stateStore.makeObservable()
    }

}

extension CameraListDependencyContainer: CameraListViewControllerFactory {

    func makeCameraViewController(with selectedIndex: Int) -> UIViewController {
        let camera = stateStore.state.dataSource.provider.items[0][selectedIndex]
        return CameraDependencyContainer(cameraProfile: camera).makeCameraViewController()
    }

    func makeAddNewCameraViewController() -> UIViewController {
        return AddNewCameraDependencyContainer().makeAddNewCameraViewController()
    }

}

//MARK: - UseCase

extension CameraListDependencyContainer: LoadCameraListUseCaseFactory {

    func makeLoadCameraListUseCase() -> UseCase {
        return LoadCameraListUseCase(actionDispatcher: actionDispatcher)
    }
}

extension CameraListDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<CameraListFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

