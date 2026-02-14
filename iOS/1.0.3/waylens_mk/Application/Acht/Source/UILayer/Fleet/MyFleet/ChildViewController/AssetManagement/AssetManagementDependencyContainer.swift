//
//  AssetManagementDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class AssetManagementDependencyContainer {

    let stateStore: ReSwift.Store<AssetManagementViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.AssetManagementReducer, state: AssetManagementViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeAssetManagementViewController() -> AssetManagementViewController {
        let stateObservable = makeAssetManagementViewControllerStateObservable()
        let observer = ObserverForAssetManagement(state: stateObservable)
        let userInterface = AssetManagementRootView()
        let viewController = AssetManagementViewController(
            observer: observer,
            vehicleListViewController: makeVehicleListViewController(),
            cameraListViewController: makeCameraListViewController()
            )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

    func makeVehicleListViewController() -> VehicleListViewController {
        return VehicleListDependencyContainer().makeVehicleListViewController()
    }

    func makeCameraListViewController() -> CameraListViewController {
        return CameraListDependencyContainer().makeCameraListViewController()
    }

}

//MARK: - Private

private extension AssetManagementDependencyContainer {

    func makeAssetManagementViewControllerStateObservable() -> Observable<AssetManagementViewControllerState> {
        return stateStore.makeObservable()
    }

}
