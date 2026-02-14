//
//  MyFleetUserProfileDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class MyFleetUserProfileDependencyContainer {

    let stateStore: ReSwift.Store<MyFleetUserProfileViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.MyFleetUserProfileReducer, state: MyFleetUserProfileViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

//    func makeMyFleetUserProfileViewController() -> MyFleetUserProfileViewController {
//        let stateObservable = makeMyFleetUserProfileViewControllerStateObservable()
//        let observer = ObserverForMyFleetUserProfile(state: stateObservable)
//        let userInterface = MyFleetUserProfileRootView()
//        let viewController = MyFleetUserProfileViewController(
//            observer: observer,
//            userInterface: userInterface
//        )
//        observer.eventResponder = viewController
//        userInterface.ixResponder = viewController
//        return viewController
//    }

}

//MARK: - Private

private extension MyFleetUserProfileDependencyContainer {

    func makeMyFleetUserProfileViewControllerStateObservable() -> Observable<MyFleetUserProfileViewControllerState> {
        return stateStore.makeObservable()
    }

}
