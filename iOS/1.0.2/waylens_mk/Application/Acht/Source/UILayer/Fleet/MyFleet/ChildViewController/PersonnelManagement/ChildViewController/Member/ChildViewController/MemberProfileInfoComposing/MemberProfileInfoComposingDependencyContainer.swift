//
//  MemberProfileInfoComposingDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class MemberProfileInfoComposingDependencyContainer {

    let stateStore: ReSwift.Store<MemberProfileInfoComposingViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.MemberProfileInfoComposingReducer, state: MemberProfileInfoComposingViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

//    func makeMemberProfileInfoComposingViewController() -> MemberProfileInfoComposingViewController {
//        let stateObservable = makeMemberProfileInfoComposingViewControllerStateObservable()
//        let observer = ObserverForMemberProfileInfoComposing(state: stateObservable)
//        let userInterface = MemberProfileInfoComposingRootView()
//        let viewController = MemberProfileInfoComposingViewController(
//            observer: observer,
//            userInterface: userInterface
//        )
//        observer.eventResponder = viewController
//        userInterface.ixResponder = viewController
//        return viewController
//    }

}

//MARK: - Private

private extension MemberProfileInfoComposingDependencyContainer {

    func makeMemberProfileInfoComposingViewControllerStateObservable() -> Observable<MemberProfileInfoComposingViewControllerState> {
        return stateStore.makeObservable()
    }

}
