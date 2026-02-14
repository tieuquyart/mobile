//
//  GeoFenceRuleListDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class GeoFenceRuleListDependencyContainer {

    let stateStore: ReSwift.Store<GeoFenceRuleListViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.GeoFenceRuleListReducer, state: GeoFenceRuleListViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeGeoFenceRuleListViewController() -> GeoFenceRuleListViewController {
        let stateObservable = makeGeoFenceRuleListViewControllerStateObservable()
        let observer = ObserverForGeoFenceRuleList(state: stateObservable)
        let userInterface = GeoFenceRuleListRootView()
        let viewController = GeoFenceRuleListViewController(
            observer: observer,
            userInterface: userInterface,
            loadGeoFenceRuleListUseCaseFactory: self,
            viewControllerFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension GeoFenceRuleListDependencyContainer {

    func makeGeoFenceRuleListViewControllerStateObservable() -> Observable<GeoFenceRuleListViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension GeoFenceRuleListDependencyContainer: GeoFenceRuleListViewControllerFactory {

    func makeViewController(for indexPath: IndexPath) -> UIViewController {
        switch indexPath.section {
        case 0:
//            return GeoFenceDraftBoxDependencyContainer().makeGeoFenceDraftBoxViewController()
//            let vc = GeoFenceListDependencyContainer(type: .unbind).makeGeoFenceListViewController()
            let vc = GeoFenceListDependencyContainer(type: .unbind).makeGeoFenceListViewControllerForDraftBox()
            vc.title = NSLocalizedString("Draft Box", comment: "Draft Box")
            return vc
        default:
            if case LoadedState.loaded(let rules) = stateStore.state.loadedState {
                let rule = rules[indexPath.row]

                return GeoFenceRuleDetailDependencyContainer(rule: rule).makeGeoFenceRuleDetailViewController()
            }
            fatalError()
        }
    }

    func makeGeoFenceRuleComposingViewController() -> UIViewController {
        return AddNewGeoFenceDependencyContainer().makeAddNewGeoFenceViewController()
    }

}

//MARK: - Use Case

extension GeoFenceRuleListDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<GeoFenceRuleListFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension GeoFenceRuleListDependencyContainer: LoadGeoFenceRuleListUseCaseFactory {

    func makeLoadGeoFenceRuleListUseCase() -> UseCase {
        return LoadGeoFenceRuleListUseCase(actionDispatcher: self.actionDispatcher)
    }

}
