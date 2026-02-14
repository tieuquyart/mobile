//
//  MyFleetSettingsDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class MyFleetSettingsDependencyContainer {

    let stateStore: ReSwift.Store<MyFleetSettingsViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.MyFleetSettingsReducer, state: MyFleetSettingsViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {
    }

    func makeMyFleetSettingsViewController() -> MyFleetSettingsViewController {
//        let observer = ObserverForMyFleetSettings(state: stateStore.state)
        let vc = MyFleetSettingsViewController.init(viewControllerFactory: self)
//        observer.eventResponder = vc as! any ObserverForMyFleetSettingsEventResponder

        return vc
    }

}

//MARK: - Private

private extension MyFleetSettingsDependencyContainer {

    func makeMyFleetSettingsViewControllerStateObservable() -> Observable<MyFleetSettingsViewControllerState> {
        return stateStore.makeObservable()
    }

}

extension MyFleetSettingsDependencyContainer: MyFleetSettingsViewControllerFactory {

    func makeViewController(with viewControllerClass: UIViewController.Type) -> UIViewController {
        switch viewControllerClass {
        case _ as AlertSettingsViewController.Type:
            return AlertSettingsDependencyContainer().makeAlertSettingsViewController()
        case _ as AboutViewController.Type:
            return UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: String(describing: AboutViewController.self))
        case _ as FeedbackController.Type:
            return FeedbackController.createViewController()
        case _ as DebugOptionViewController.Type:
            return UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: String(describing: DebugOptionViewController.self))
            
        case _ as HNAlbumViewController.Type:
            return UIStoryboard(name: "Library", bundle: nil).instantiateInitialViewController()!
        case _ as SecureEsNetworkSetupWayViewController.Type:
            return SecureEsNetworkMobilePhoneStepOneDependencyContainer().makeSecureEsNetworkMobilePhoneStepOneViewController().embedInNavigationController()
        default:
            return viewControllerClass.init()
        }
    }

}
