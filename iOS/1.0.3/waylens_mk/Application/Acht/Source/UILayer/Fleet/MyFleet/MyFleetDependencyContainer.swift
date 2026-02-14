//
//  MyFleetDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class MyFleetDependencyContainer {
    
    
   
    let stateStore: ReSwift.Store<MyFleetViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.myFleetReducer, state: MyFleetViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeMyFleetViewController() -> MyFleetViewController {
        let stateObservable = makeMyFleetViewControllerStateObservable()
        let stateObserver = ObserverForMyFleet(state: stateObservable)
        let cameraObserver = ObserverForCurrentConnectedCamera()
        let composedObservers =
            ObserverComposition(observers: stateObserver, cameraObserver)

        let userInterface = MyFleetRootView()
        let myFleetViewController = MyFleetViewController(
            observer: composedObservers,
            userInterface: userInterface,
            reloadUserProfileUseCaseFactory: self,
            viewControllerFactory: self
        )
        stateObserver.eventResponder = myFleetViewController
        cameraObserver.eventResponder = myFleetViewController
        userInterface.ixResponder = myFleetViewController
        return myFleetViewController
    }
    
    

}

extension MyFleetDependencyContainer: ReloadUserProfileUseCaseFactory {

    func makeReloadUserProfileUseCase() -> UseCase {
        return ReloadUserProfileUseCase(actionDispatcher: actionDispatcher)
    }

}

extension MyFleetDependencyContainer: MyFleetViewControllerFactory {

    func makeViewController(with viewControllerClass: UIViewController.Type) -> UIViewController {
        switch viewControllerClass {
        case _ as MyFleetUserProfileViewController.Type:
            let userInterface = MyFleetUserProfileRootView()
            let vc = MyFleetUserProfileViewController(userProfile: stateStore.state.userProfile, userInterface: userInterface)
            userInterface.ixResponder = vc
            return vc
        case _ as PersonnelManagementViewController.Type:
            return PersonnelManagementDependencyContainer().makePersonnelManagementViewController()
        case _ as AssetManagementViewController.Type:
            return AssetManagementDependencyContainer().makeAssetManagementViewController()
        case _ as MyFleetSettingsViewController.Type:
            return MyFleetSettingsDependencyContainer().makeMyFleetSettingsViewController()
        case _ as DataUsageViewController.Type:
            return DataUsageDependencyContainer().makeDataUsageViewController()
        case _ as HNAlbumViewController.Type:
            return UIStoryboard(name: "Library", bundle: nil).instantiateInitialViewController()!
        case _ as HNCameraDetailViewController.Type:
            let vc = HNCameraDetailViewController.createViewController(camera: UnifiedCameraManager.shared.local,isCameraPickerEnabled: false)
            return vc
        case _ as TypeDataTCVNViewController.Type:
            let vc = TypeDataTCVNViewController()
           //  let vc = HNCSNetworkViewController()
            vc.camera = UnifiedCameraManager.shared.local
            return vc
        case _ as GeoFenceRuleListViewController.Type:
            return GeoFenceRuleListDependencyContainer().makeGeoFenceRuleListViewController()
        case _ as ConfigCameraMKViewController.Type:
            let vc = ConfigCameraMKViewController()
            vc.camera = UnifiedCameraManager.shared.local
            return vc
        default:
            return viewControllerClass.init()
        }
    }

}

//MARK: - Private

private extension MyFleetDependencyContainer {

    func makeMyFleetViewControllerStateObservable() -> Observable<MyFleetViewControllerState> {
        return stateStore.makeObservable()
    }
    
}
